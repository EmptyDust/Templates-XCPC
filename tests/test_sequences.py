import random
import unittest
from support import check, compile_program, printed, run


class SequenceTests(unittest.TestCase):
    def test_double_hash_hypothetical_replacement(self):
        source=printed('code/杂项/取模类.cpp')+printed('chapters/串.typ','双哈希封装')
        check('double_hash',source+r'''
int main() {
    init(30);
    mt19937 rng(392);
    assert((String("").get() == pair<U, V>{1, 1}));
    for (int trial = 0; trial < 100; ++trial) {
        string text;
        for (int i = 0, n = 1 + rng() % 30; i < n; ++i) text += char('a' + rng() % 4);
        const String hash(text);
        auto original = hash.get();
        for (int l = 0; l < text.size(); ++l) {
            U first = 0;
            V second = 0;
            for (int r = l; r < text.size(); ++r) {
                first = first * base1 + text[r];
                second = second * base2 + text[r];
                assert((hash.substring(l, r) == pair<U, V>{first, second}));
            }
            string changed = text;
            changed[l] = char('a' + rng() % 4);
            assert(hash.modify(l, changed[l]) == String(changed).get());
            assert(hash.get() == original);
        }
    }
}
''')

    def test_suffix_structures_and_kmp(self):
        source = ''.join(printed(p) for p in ['code/串/kmp.cpp','code/串/kmp-2.cpp',
                'code/串/后缀数组-SA.cpp','code/串/后缀自动机-SAM-2.cpp','code/串/后缀自动机-SAM.cpp'])
        check('suffix_structures',source+r'''
int main() {
    mt19937 rng(384);
    for(int trial=0;trial<250;++trial){
        string s;
        for(int i=0,n=rng()%30;i<n;++i)s+=char('a'+rng()%3);
        SuffixArray sa(s);
        vector<int> expected(s.size());iota(expected.begin(),expected.end(),0);
        sort(expected.begin(),expected.end(),[&](int x,int y){return s.substr(x)<s.substr(y);});
        assert(expected==sa.sa);
        for(int i=1;i<s.size();++i){int k=0;while(sa.sa[i]+k<s.size()&&sa.sa[i-1]+k<s.size()&&s[sa.sa[i]+k]==s[sa.sa[i-1]+k])++k;assert(sa.lc[i-1]==k);}
        SAM sam(s);
        for(int phase=0;phase<2;++phase){
            if(phase){s+='b';sam.extend('b',s.size());}
            auto count=sam.countOccurrences();assert(count==sam.countOccurrences());
            for(int len=1;len<=6;++len)for(int bits=0;bits<(1<<len);++bits){
                string pattern;for(int j=0;j<len;++j)pattern+=char('a'+(bits>>j&1));
                int occurrences=0;
                for(int pos=0;pos+len<=s.size();++pos)occurrences+=s.substr(pos,len)==pattern;
                assert(kmp(s,pattern)==bool(occurrences));
                int p=0;
                for(char c:pattern){auto it=sam.nodes[p].next.find(c);if(it==sam.nodes[p].next.end()){p=-1;break;}p=it->second;}
                assert((p==-1?0:count[p])==occurrences);
                if(p!=-1){int end=sam.nodes[p].endpos;assert(end>=len&&s.substr(end-len,len)==pattern);}
            }
        }
    }
    assert(kmp("","")&&kmp("a","")&&!kmp("","a"));
    assert((get_next("a")==vector<int>{-1,0}));
    // 堆上构造，不借助全局零初始化；复用对象插入多串。
    auto generalized=make_unique<SuffixAutomaton>();
    set<string> substrings;
    vector<string> strings={"abbb","ba","baba","aa","abbb"};
    for(const auto &s:strings){
        int last=SuffixAutomaton::root;
        for(char c:s)last=generalized->extend(last,c-'a');
        for(int l=0;l<s.size();++l)for(int r=l+1;r<=s.size();++r)substrings.insert(s.substr(l,r-l));
        i64 distinct=0;
        for(int v=2;v<=generalized->cntNodes;++v)distinct+=generalized->t[v].len-generalized->t[generalized->t[v].link].len;
        assert(distinct==(int)substrings.size());
        for(const auto &t:substrings){int p=1;for(char c:t){p=generalized->t[p].nxt[c-'a'];assert(p>1);}}
    }
}
''')
        run(compile_program('generalized_sam_example',printed('code/串/后缀自动机-SAM.cpp')+
                            printed('chapters/串.typ','后缀自动机-sam')),'2\nab\nba\n','4')

    def test_aho_corasick_repeated_queries(self):
        check('aho_corasick',printed('code/串/AC-自动机.cpp')+printed('code/串/AC-自动机-2.cpp')+r'''
int main(){
    mt19937 rng(447);
    auto one=make_unique<ACAutomaton>();
    AhoCorasick all;
    vector<string> patterns={"a","aa","a","ab","b","bb","baa"};vector<int> endpoints;
    for(const auto &s:patterns){one->insert(s);endpoints.push_back(all.add(s));}
    one->build();one->build();all.get_fail();all.get_fail();
    for(int trial=0;trial<150;++trial){
        string text;for(int i=0,n=rng()%40;i<n;++i)text+=char('a'+rng()%2);
        auto counts=all.work(text);assert(counts==all.work(text));
        int distinct=0;
        for(int i=0;i<patterns.size();++i){
            int count=0;for(int p=0;p+patterns[i].size()<=text.size();++p)count+=text.substr(p,patterns[i].size())==patterns[i];
            assert(counts[endpoints[i]]==count);distinct+=count>0;
        }
        assert(one->query(text)==distinct&&one->query(text)==distinct);
    }
    all.init();int a=all.add("a");assert(all.work("a")[a]==1&&all.work("a")[a]==1);
}
''')

    def test_knapsack(self):
        mixed=compile_program('mixed_knapsack',printed('code/动态规划/混合背包.cpp'))
        bounded=compile_program('bounded_knapsack',printed('code/动态规划/多重背包-2.cpp'))
        run(mixed,'1 1\n1 1 1\n','1')
        rng=random.Random(876)
        for exe,is_mixed in [(mixed,True),(bounded,False)]:
            for _ in range(70):
                n=rng.randrange(1,6);capacity=rng.randrange(12)
                items=[(rng.randrange(1,7),rng.randrange(-4,20),rng.randrange(-1 if is_mixed else 0,6)) for _ in range(n)]
                dp=[0]*(capacity+1)
                for w,v,c in items:
                    count=(1 if c==-1 else capacity//w if c==0 else c) if is_mixed else c
                    dp=[max(dp[j-k*w]+k*v for k in range(min(count,j//w)+1)) for j in range(capacity+1)]
                data=f'{n} {capacity}\n'+''.join(f'{w} {v} {c}\n' for w,v,c in items)
                run(exe,data,str(dp[-1]))
        run(mixed,'1 2\n1 4000000000 2147483647\n','8000000000')

    def test_brackets(self):
        block=printed('chapters/动态规划.typ','常用例题',1)
        check('brackets',block.split('int main()')[0]+r'''
int main(){
    string chars="()[]";
    for(int n=0;n<=8;++n)for(int mask=0;mask<(1<<(2*n));++mask){
        string s;for(int i=0;i<n;++i)s+=chars[mask>>(2*i)&3];
        string expected;
        for(int l=0;l<n;++l){
            vector<char> stack;
            for(int r=l;r<n;++r){
                if(s[r]=='('||s[r]=='[')stack.push_back(s[r]);
                else {
                    if(stack.empty()||(s[r]==')'?stack.back()!='(':stack.back()!='['))break;
                    stack.pop_back();
                }
                if(stack.empty()&&r-l+1>expected.size())expected=s.substr(l,r-l+1);
            }
        }
        assert(longestBrackets(s)==expected);
    }
}
''')
        run(compile_program('brackets_example',block),'())\n','()')

    def test_lis_examples(self):
        one=compile_program('lis_one',printed('code/杂项/一维.cpp'))
        two=compile_program('lis_two',printed('code/杂项/二维+输出方案.cpp'))
        rng=random.Random(664)
        for _ in range(90):
            n=rng.randrange(10);a=[rng.randrange(-5,6) for _ in range(n)]
            dp=[1]*n
            for i in range(n):dp[i]=1+max([dp[j] for j in range(i) if a[j]<a[i]],default=0)
            run(one,str(n)+'\n'+' '.join(map(str,a))+'\n',str(max(dp,default=0)))
            points=[(rng.randrange(-5,6),rng.randrange(-5,6)) for _ in range(n)]
            dp=[1]*n
            for i in sorted(range(n),key=lambda i:points[i]):
                dp[i]=1+max([dp[j] for j in range(n) if points[j][0]<points[i][0] and points[j][1]<points[i][1]],default=0)
            result=list(map(int,run(two,str(n)+'\n'+''.join(f'{x} {y}\n' for x,y in points)).split()))
            self.assertEqual(result[0],max(dp,default=0))
            self.assertEqual(result[0],len(result)-1)
            selected=[points[v-1] for v in result[1:]]
            self.assertTrue(all(x[0]<y[0] and x[1]<y[1] for x,y in zip(selected,selected[1:])))


    def test_game_recurrences(self):
        source=printed('chapters/博弈论.typ','反常规则-dag')+printed('chapters/博弈论.typ','every-sg-步数')
        check('games',source+r'''
int main(){
    // 穷举 5 点的全部 DAG，逐组合状态枚举“一回合移动全部活跃分量”的后继。
    const int n=5;
    for(int mask=0;mask<(1<<(n*(n-1)/2));++mask){
        vector<vector<int>> adj(n);int bit=0;
        for(int x=1;x<n;++x)for(int y=0;y<x;++y)if(mask>>bit++&1)adj[x].push_back(y);
        auto step=everySG(adj);auto misere=misereWin(adj);
        vector<bool> expected(n);
        for(int x=0;x<n;++x){expected[x]=adj[x].empty();for(int y:adj[x])expected[x]=expected[x]||!expected[y];}
        assert(misere==expected);
        map<array<int,3>,bool> memo;
        auto win=[&](auto &&self,array<int,3> state)->bool{
            if(memo.count(state))return memo[state];
            bool active=false,winning=false;
            for(int x:state)active|=!adj[x].empty();
            if(!active)return memo[state]=false;
            array<int,3> next;
            auto moves=[&](auto &&enumerate,int i)->void{
                if(i==3){if(!self(self,next))winning=true;return;}
                if(adj[state[i]].empty()){next[i]=state[i];enumerate(enumerate,i+1);}
                else for(int v:adj[state[i]]){next[i]=v;enumerate(enumerate,i+1);}
            };moves(moves,0);return memo[state]=winning;
        };
        for(int a=0;a<n;++a)for(int b=0;b<n;++b)for(int c=0;c<n;++c)
            assert(win(win,{a,b,c})==bool(max({step[a],step[b],step[c]})%2));
    }
    assert((misereWin({{},{0},{0,1},{2}})==vector<bool>{true,false,true,false}));
}
''')
        run(compile_program('every_sg_example',printed('chapters/博弈论.typ','every-sg-步数')+
                            printed('chapters/博弈论.typ','every-sg-步数',1)),
            '3 2 2\n1 0\n2 1\n1 2\n','Second')
