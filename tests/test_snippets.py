import re
import unittest
from support import ROOT, check
from sync_snippets import SOURCES, escape, inserted, load_snippets, printed


class SnippetTests(unittest.TestCase):
    def test_graph_components_compose_after_insertion(self):
        snippets = load_snippets(ROOT / "code-snippets/tree_and_graph.code-snippets")
        keys = ['dijkstra', 'bf', 'add', 'add_2', 'maxcostmatch', 'dag', 'for_3']
        source = '\n'.join(inserted(snippets[key]['body']) for key in keys)
        check('inserted_graph_components', source + r'''
int main() {
    vector<vector<pair<int, i64>>> adj(3);
    adj[0].push_back({1, 4});
    adj[1].push_back({2, 5});
    assert((dijkstra(adj, 0) == vector<i64>{0, 4, 9}));
    assert((spfa(adj, 0) == vector<i64>{0, 4, 9}));
    assert(!hasNegativeCycle(adj));
    adj[2].push_back({1, -6});
    assert(hasNegativeCycle(adj) && spfa(adj, 0).empty());
    vector<tuple<int, int, i64>> edges{{1, 2, 4}, {2, 3, 5}};
    assert(bellmanFord(3, edges, 1, 2)[3] == 9);
    MaxCostMatch match(1);
    match.add(1, 1, -7);
    assert(match.work() == -7 && match.ok && match.ansl[1] == 1);
    DAG dag(3);
    dag.add(1, 2, 4);
    dag.add(2, 3, 5);
    assert(dag.topsort(1, 3) == 9);
    vector<vector<int>> tournament{{0, 1, 0}, {0, 0, 1}, {1, 0, 0}};
    auto [a, b, c] = tournamentTriangle(tournament);
    assert(a >= 0 && tournament[a][b] && tournament[b][c] && tournament[c][a]);
}
''')

    def test_synchronized_sources_and_literal_insertion(self):
        for file, key, sources in SOURCES:
            with self.subTest(file=file, key=key):
                source = "\n".join(printed(*s) for s in sources)
                body = load_snippets(ROOT / "code-snippets" / (file + ".code-snippets"))[key]["body"]
                self.assertEqual(body, escape(source))
                self.assertEqual(inserted(body), source)

    def test_no_invalid_member_qualification(self):
        for path in (ROOT / "code-snippets").glob("*.code-snippets"):
            for key, entry in load_snippets(path).items():
                with self.subTest(file=path.name, key=key):
                    body = inserted(entry["body"])
                    self.assertNotRegex(body, r"(?:\.|->)std::|std::ios::std::|numeric_limits<[^>]+>::std::")


if __name__ == "__main__":
    unittest.main()
