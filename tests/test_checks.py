import unittest
from support import BUILD
from check_pdf import check


class PdfChecks(unittest.TestCase):
    def test_type3_and_invalid_pdf_are_rejected(self):
        BUILD.mkdir(parents=True, exist_ok=True)
        def stream(data):
            return f"<< /Length {len(data)} >>\nstream\n".encode() + data + b"\nendstream"
        objects = [
            b"<< /Type /Catalog /Pages 2 0 R >>",
            b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
            b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 100 100] /Resources << /Font << /F1 4 0 R >> >> /Contents 6 0 R >>",
            b"<< /Type /Font /Subtype /Type3 /FontBBox [0 0 500 500] /FontMatrix [.001 0 0 .001 0 0] /CharProcs << /a 5 0 R >> /Encoding << /Type /Encoding /Differences [97 /a] >> /FirstChar 97 /LastChar 97 /Widths [500] /Resources << >> >>",
            stream(b"500 0 0 0 500 500 d1\n0 0 500 500 re f"),
            stream(b"BT /F1 12 Tf 10 10 Td (a) Tj ET"),
        ]
        data = b"%PDF-1.4\n"
        offsets = [0]
        for i, obj in enumerate(objects, 1):
            offsets.append(len(data))
            data += f"{i} 0 obj\n".encode() + obj + b"\nendobj\n"
        xref = len(data)
        data += b"xref\n0 7\n0000000000 65535 f \n"
        for offset in offsets[1:]:
            data += f"{offset:010d} 00000 n \n".encode()
        data += f"trailer\n<< /Size 7 /Root 1 0 R >>\nstartxref\n{xref}\n%%EOF\n".encode()
        type3 = BUILD / "type3.pdf"
        type3.write_bytes(data)
        with self.assertRaisesRegex(RuntimeError, "Type 3"):
            check(type3)
        invalid = BUILD / "invalid.pdf"
        invalid.write_bytes(b"not a PDF")
        with self.assertRaisesRegex(RuntimeError, "pdffonts"):
            check(invalid)


class PdfDestinations(unittest.TestCase):
    def test_named_destinations_and_invalid_targets(self):
        import importlib.util
        import subprocess
        import sys
        from pypdf import PdfWriter, PdfReader
        from pypdf.generic import ArrayObject, DictionaryObject, NameObject, NumberObject, TextStringObject
        from check_pdf import check_links
        from support import ROOT

        BUILD.mkdir(parents=True, exist_ok=True)
        spec = importlib.util.spec_from_file_location('flatten_pdf', ROOT / 'export/flatten-pdf-dests.py')
        flatten = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(flatten)
        writer = PdfWriter()
        writer.add_blank_page(100, 100)
        writer.add_blank_page(100, 100)
        dest = ArrayObject([writer.pages[1].indirect_reference, NameObject('/Fit')])
        leaf = DictionaryObject({NameObject('/Names'): ArrayObject([TextStringObject('章节'), dest])})
        writer.root_object[NameObject('/Names')] = DictionaryObject({
            NameObject('/Dests'): DictionaryObject({NameObject('/Kids'): ArrayObject([leaf])})})
        for action in [False, True]:
            annotation = DictionaryObject({NameObject('/Subtype'): NameObject('/Link'),
                NameObject('/Rect'): ArrayObject([NumberObject(0), NumberObject(0), NumberObject(10), NumberObject(10)])})
            if action:
                annotation[NameObject('/A')] = DictionaryObject({NameObject('/S'): NameObject('/GoTo'), NameObject('/D'): TextStringObject('章节')})
            else:
                annotation[NameObject('/Dest')] = TextStringObject('章节')
            writer.pages[0].setdefault(NameObject('/Annots'), ArrayObject()).append(writer._add_object(annotation))
        writer.add_outline_item('章节', 1)
        source, output = BUILD/'named.pdf', BUILD/'explicit.pdf'
        writer.write(source)
        with self.assertRaisesRegex(RuntimeError, '未展开'):
            check_links(source)
        self.assertEqual(flatten.flatten(source, output), (2, 0))
        check_links(output)
        self.assertEqual(len(PdfReader(output).pages), 2)

        writer.pages[0]['/Annots'][0].get_object()[NameObject('/Dest')] = TextStringObject('missing')
        writer.write(source)
        original = source.read_bytes()
        result = subprocess.run([sys.executable, str(ROOT/'export/flatten-pdf-dests.py'), str(source)],
                                capture_output=True, text=True, timeout=30)
        self.assertEqual(result.returncode, 1)
        self.assertEqual(source.read_bytes(), original)

        # PDF 对象存在，但它是页面树而非具体页面，不能作为本地跳转目标。
        writer.pages[0]['/Annots'][0].get_object()[NameObject('/Dest')] = ArrayObject([writer._pages, NameObject('/Fit')])
        writer.write(source)
        with self.assertRaisesRegex(RuntimeError, '不存在的页面'):
            check_links(source)


class TypstChecks(unittest.TestCase):
    def test_code_regions_and_marker_errors(self):
        import subprocess
        import tempfile
        from pathlib import Path
        from pypdf import PdfReader
        from support import ROOT

        BUILD.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=BUILD) as directory:
            directory = Path(directory)
            source, main, pdf = directory/'sample.cpp', directory/'main.typ', directory/'out.pdf'
            path = source.relative_to(ROOT).as_posix()
            main.write_text(f'#import "/prelude.typ": include-code\n#include-code("{path}")\n'
                            f'#include-code("{path}", region: "example")\n')
            command = ['typst', 'compile', '--root', str(ROOT), str(main), str(pdf)]
            source.write_text('int outside;\n  // @book-begin\n    int book_value;\n'
                              '  // @book-end\n// @example-begin\nint example_value;\n// @example-end\n')
            result = subprocess.run(command, capture_output=True, text=True, timeout=60)
            self.assertEqual(result.returncode, 0, result.stderr)
            text = PdfReader(pdf).pages[0].extract_text()
            self.assertIn('book_value', text)
            self.assertIn('example_value', text)
            self.assertNotIn('outside', text)

            cases = [
                ('// @book-end\n', '@book-begin'),
                ('// @book-begin\n', '@book-end'),
                ('// @book-begin\n// @book-begin\n// @book-end\n', '@book-begin'),
                ('// @book-begin\n// @book-end\n// @book-end\n', '@book-end'),
                ('// @book-end\n// @book-begin\n', 'must precede'),
            ]
            for body, diagnostic in cases:
                with self.subTest(body=body):
                    source.write_text(body)
                    result = subprocess.run(command, capture_output=True, text=True, timeout=60)
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn(path, result.stderr)
                    self.assertIn(diagnostic, result.stderr)


if __name__ == "__main__":
    unittest.main()
