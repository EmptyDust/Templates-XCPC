import itertools
import random
import unittest
from support import check, compile_program, printed, run


def example(path):
    return printed(path) + printed(path, region='example')


class GraphTests(unittest.TestCase):
    def test_random_connected_graph(self):
        check('random_graph',printed('code/杂项/随机数生成与样例构造.cpp')+r'''
int main(){
    rnd.seed(1);
    for(int n=1;n<=25;++n)for(int m=n-1;m<=n*(n-1)/2;++m){
        auto edges=graph(n,-1,m);assert(edges.size()==m);
        set<pair<int,int>> distinct(edges.begin(),edges.end());assert(distinct.size()==m);
        vector<vector<int>> adj(n+1);
        for(auto [u,v]:edges){assert(1<=u&&u<v&&v<=n);adj[u].push_back(v);adj[v].push_back(u);}
        set<int> seen{1};vector<int> q{1};
        for(int p=0;p<q.size();++p)for(int v:adj[q[p]])if(seen.insert(v).second)q.push_back(v);
        assert(seen.size()==n);
    }
    for(int i=0;i<100;++i){int x=r(INT_MIN,INT_MAX);(void)x;}
    assert(graph(3,0,3).size()==3);
}
''')


    def test_scc_and_graph_lifecycle(self):
        check('scc_graph', printed('chapters/图论.typ', '有向图强连通分量缩点') +
              printed('chapters/图论.typ', '链式前向星建图与搜索') + r'''
int main() {
    Graph::clear(2);
    Graph::add(1, 2); Graph::add(2, 1);
    assert(!Graph::topsort() && !Graph::topsort());
    Graph::clear(3);
    Graph::add(1, 2); Graph::add(2, 3);
    assert(Graph::topsort() && Graph::topsort());
    Graph::bfs(1); assert(Graph::dis[3] == 3);
    Graph::bfs(2); assert(Graph::dis[1] == 0 && Graph::dis[3] == 2);
    Graph::dfs(1); assert(Graph::siz[1] == 3);
    Graph::clear(1); assert(Graph::a.empty() && Graph::siz[1] == 0);
    mt19937 rng(732);
    for (int trial = 0; trial < 300; ++trial) {
        int n = 1 + rng() % 8;
        SCC scc(n);
        vector reach(n + 1, vector<int>(n + 1));
        for (int phase = 0; phase < 3; ++phase) {
            for (int x = 1; x <= n; ++x) for (int y = 1; y <= n; ++y) {
                if (rng() % 7 == 0) { scc.add(x,y); reach[x][y] = 1; }
            }
            for (int i = 1; i <= n; ++i) reach[i][i] = 1;
            for (int k = 1; k <= n; ++k) for (int x = 1; x <= n; ++x)
                for (int y = 1; y <= n; ++y) reach[x][y] |= reach[x][k] && reach[k][y];
            auto [cnt, adj, col, siz] = scc.work();
            assert(scc.work() == tuple(cnt, adj, col, siz));
            assert(accumulate(siz.begin(), siz.end(), 0) == n);
            for (int x = 1; x <= n; ++x) for (int y = 1; y <= n; ++y)
                assert((col[x] == col[y]) == (reach[x][y] && reach[y][x]));
            for (int x = 1; x <= cnt; ++x) for (int y : adj[x]) assert(x > y);
        }
    }
}
''')

    def test_matching_and_dag(self):
        match = 'code/图论/二分图最大权匹配-二分图完美匹配.cpp'
        dag = 'code/图论/最长路-topsort+DP-算法.cpp'
        check('matching_dag', printed(match) + printed(dag) + r'''
int main() {
    mt19937 rng(878);
    for (int trial = 0; trial < 500; ++trial) {
        int n = 1 + rng() % 6;
        MaxCostMatch m(n);
        vector p(n, 0); iota(p.begin(), p.end(), 1);
        vector w(n + 1, vector<i64>(n + 1));
        vector has(n + 1, vector<bool>(n + 1));
        for (int x = 1; x <= n; ++x) for (int y = 1; y <= n; ++y) {
            if (rng() % 3) {
                has[x][y] = true;
                w[x][y] = (int(rng() % 21) - 10) * (trial % 2 ? (1LL << 51) : 1);
                m.add(x,y,w[x][y]); m.add(x,y,w[x][y]-1);
            }
        }
        optional<i64> expected;
        do {
            bool valid = true; i64 cost = 0;
            for (int x = 1; x <= n; ++x) { valid &= has[x][p[x-1]]; cost += w[x][p[x-1]]; }
            if (valid && (!expected || cost > *expected)) expected = cost;
        } while (next_permutation(p.begin(), p.end()));
        for (int repeat = 0; repeat < 2; ++repeat) {
            i64 actual = m.work();
            assert(m.ok == expected.has_value());
            if (m.ok) {
                assert(actual == *expected);
                i64 cost = 0;
                for (int x = 1; x <= n; ++x) {
                    assert(m.ansr[m.ansl[x]] == x && has[x][m.ansl[x]]);
                    cost += w[x][m.ansl[x]];
                }
                assert(cost == actual);
            }
        }
    }
    const i64 weight = (1LL << 56) - 1;
    MaxCostMatch big(2);
    big.add(1,1,-weight); big.add(2,2,weight-1);
    assert(big.work() == -1 && big.ok);
    MaxCostMatch missing(2);
    missing.add(1,1,0); missing.add(2,1,0);
    missing.work(); assert(!missing.ok);
    missing.add(2,2,-1); assert(missing.work() == -1 && missing.ok);
    missing.add(2,2,0); assert(missing.work() == 0 && missing.ok);
    for (int trial = 0; trial < 200; ++trial) {
        int n = 1 + rng() % 8;
        DAG dag(n);
        vector edge(n + 1, vector<optional<i64>>(n + 1));
        for (int x = 1; x <= n; ++x) for (int y = x + 1; y <= n; ++y)
            if (rng() % 3 == 0) {
                edge[x][y] = (int(rng() % 31) - 15) * (trial % 2 ? (1LL << 51) : 1);
                dag.add(x,y,*edge[x][y]);
            }
        for (int s = 1; s <= n; ++s) {
            vector<optional<i64>> answer(n + 1);
            auto dfs = [&](auto &&self, int x, i64 cost) -> void {
                if (!answer[x] || cost > *answer[x]) answer[x] = cost;
                for (int y = x+1; y <= n; ++y) if (edge[x][y]) self(self,y,cost+*edge[x][y]);
            };
            dfs(dfs,s,0);
            for (int t = 1; t <= n; ++t) assert(dag.topsort(s,t) == answer[t].value_or(-DAG::inf));
        }
    }
    DAG extreme(4);
    extreme.add(1,2,-weight); extreme.add(2,3,weight-1);
    extreme.add(4,3,weight-1);
    assert(extreme.topsort(1,3) == -1);
    assert(extreme.topsort(1,4) == -DAG::inf);
}
''')
        match_example = compile_program('matching_example', example(match))
        self.assertEqual(run(match_example, '1 2 2\n1 1 -2\n1 2 0\n').split(), ['0','2','0','1'])
        self.assertEqual(run(match_example, '1 1 1\n1 1 -1\n').split(), ['-1','1','1'])
        run(match_example, '2 1 2\n1 1 0\n2 1 0\n', 'No Solution')
        dag_example = compile_program('dag_example', example(dag))
        run(dag_example, '3 1\n2 3 100\n1 3\n', 'N')
        run(dag_example, '2 1\n1 2 0\n1 2\n', '0')
        run(dag_example, '2 1\n1 2 -1\n1 2\n', '-1')

    def test_min_cycles(self):
        check('minimum_cycles', printed('chapters/图论.typ', '带权最小环大小与计数') +
              printed('chapters/图论.typ', '最小环大小') + r'''
int main() {
    mt19937 rng(837);
    for (bool directed : {false, true}) for (int trial = 0; trial < 500; ++trial) {
        int n = 1 + rng() % 7;
        vector edge(n, vector<i64>(n, -1));
        for (int x = 0; x < n; ++x) for (int y = directed ? 0 : x+1; y < n; ++y) {
            if (rng() % 3 == 0) {
                edge[x][y] = rng() % 6 + directed;
                if (!directed) edge[y][x] = edge[x][y];
            }
        }
        i64 best = LLONG_MAX; int count = 0;
        for (int start = 0; start < n; ++start) {
            auto dfs = [&](auto &&self, int x, int mask, i64 weight, int length) -> void {
                if (edge[x][start] >= 0 && (directed || length >= 3)) {
                    i64 value = weight + edge[x][start];
                    if (value < best) { best = value; count = 1; }
                    else if (value == best) ++count;
                }
                for (int y = start+1; y < n; ++y) if (!(mask >> y & 1) && edge[x][y] >= 0)
                    self(self,y,mask|(1<<y),weight+edge[x][y],length+1);
            };
            dfs(dfs,start,1<<start,0,1);
        }
        if (best == LLONG_MAX) best = -1;
        if (directed) for (int p : {1, 7, INT_MAX}) assert(directedMinCycle(edge,p) == pair(best,count%p));
        else assert(minCycle(edge) == best);
    }
    vector edge(2, vector<i64>(2,-1)); edge[0][1]=edge[1][0]=1100000000LL;
    assert((directedMinCycle(edge) == pair<i64,int>(2200000000LL,1)));
}
''')

    def test_tournament_triangle(self):
        check('tournament_component', printed('code/图论/输出任意一个三元环.cpp') + r'''
int main() {
    for (int n = 1; n <= 6; ++n) {
        int edges = n * (n - 1) / 2;
        for (int mask = 0; mask < (1 << edges); ++mask) {
            vector a(n, vector<int>(n));
            int bit = 0;
            for (int x = 0; x < n; ++x) for (int y = x + 1; y < n; ++y) {
                a[x][y] = mask >> bit++ & 1;
                a[y][x] = !a[x][y];
            }
            bool exists = false;
            for (int x = 0; x < n; ++x) for (int y = 0; y < n; ++y)
                for (int z = 0; z < n; ++z) exists |= a[x][y] && a[y][z] && a[z][x];
            auto answer = tournamentTriangle(a);
            assert(tournamentTriangle(a) == answer);
            auto [x, y, z] = answer;
            assert((x != -1) == exists);
            if (exists) assert(a[x][y] && a[y][z] && a[z][x]);
        }
    }
}
''')
        exe = compile_program('tournament_triangle', example('code/图论/输出任意一个三元环.cpp'))
        for n in range(1, 5):
            pairs = list(itertools.combinations(range(n), 2))
            for mask in range(1 << len(pairs)):
                a = [[0]*n for _ in range(n)]
                for bit, (x,y) in enumerate(pairs):
                    a[x][y] = (mask >> bit) & 1
                    a[y][x] = 1 - a[x][y]
                exists = any(a[x][y] and a[y][z] and a[z][x] for x,y,z in itertools.permutations(range(n),3))
                data = str(n)+'\n'+'\n'.join(''.join(map(str,row)) for row in a)+'\n'
                result = list(map(int, run(exe,data).split()))
                if exists:
                    self.assertEqual(len(result),3)
                    x,y,z = (v-1 for v in result)
                    self.assertTrue(a[x][y] and a[y][z] and a[z][x])
                else:
                    self.assertEqual(result,[-1])

    def test_tree_components(self):
        check('tree_components', printed('code/树上问题/HLD.cpp') +
              printed('code/树上问题/树上路径交.cpp') + r'''
int main() {
    mt19937 rng(823);
    for (int trial = 0; trial < 80; ++trial) {
        int n = 1 + rng()%20;
        HLD h(n);
        vector<vector<int>> adj(n+1);
        for (int x = 2; x <= n; ++x) {
            int y = 1+rng()%(x-1); h.add(x,y); adj[x].push_back(y); adj[y].push_back(x);
        }
        auto vertices = [&](int s, int t) {
            vector<int> pre(n+1,-1), path;
            queue<int> q; q.push(s); pre[s]=0;
            while (!q.empty()) { int x=q.front(); q.pop(); for (int y:adj[x]) if (pre[y]<0) {pre[y]=x;q.push(y);} }
            for (int x=t;x;x=pre[x]) path.push_back(x);
            sort(path.begin(),path.end()); return path;
        };
        for (int root : {1,n,1}) {
            h.work(root);
            for (int q = 0; q < 300; ++q) {
                int a=1+rng()%n,b=1+rng()%n,c=1+rng()%n,d=1+rng()%n;
                auto first=vertices(a,b), second=vertices(c,d);
                vector<int> both,actual;
                set_intersection(first.begin(),first.end(),second.begin(),second.end(),back_inserter(both));
                assert(intersection(a,b,c,d,h.dep,[&](int x,int y){return h.lca(x,y);}) == (int)both.size());
                h.path(a,b,[&](int l,int r){for(int x=1;x<=n;++x)if(l<=h.in[x]&&h.in[x]<=r)actual.push_back(x);});
                sort(actual.begin(),actual.end()); assert(first==actual);
                assert(h.dist(a,b)==(int)first.size()-1);
            }
        }
    }
}
''')
        source = printed('code/树上问题/HLD.cpp')
        source += printed('chapters/树上问题.typ','轻重链剖分树链剖分')
        source += printed('chapters/树上问题.typ','轻重链剖分树链剖分',1)
        exe = compile_program('hld_example',source)
        rng = random.Random(713)
        for n in [1,2,13,40]:
            root=rng.randrange(n)
            order=list(range(n)); rng.shuffle(order)
            edges=[(order[x],order[rng.randrange(x)]) for x in range(1,n)]
            adj=[[] for _ in range(n)]
            for x,y in edges: adj[x].append(y); adj[y].append(x)
            parent=[-1]*n; parent[root]=root
            queue=[root]
            for x in queue:
                for y in adj[x]:
                    if parent[y]<0: parent[y]=x; queue.append(y)
            def path(x,y):
                left=[x]; right=[y]
                while left[-1]!=root: left.append(parent[left[-1]])
                while right[-1]!=root: right.append(parent[right[-1]])
                while len(left)>1 and len(right)>1 and left[-2]==right[-2]: left.pop();right.pop()
                return left+right[-2::-1]
            def subtree(x):
                return [v for v in range(n) if x in path(v,root)]
            values=[rng.randrange(-10**10,10**10) for _ in range(n)]
            lines=[f'{n} 150 {root+1}',' '.join(map(str,values))]+[f'{x+1} {y+1}' for x,y in edges]
            expected=[]
            for _ in range(150):
                op=rng.randrange(1,5); x=rng.randrange(n);y=rng.randrange(n); v=rng.randrange(-10**10,10**10)
                vertices=path(x,y) if op<=2 else subtree(x)
                if op in [1,3]:
                    lines.append(f'{op} {x+1} '+(f'{y+1} ' if op==1 else '')+str(v))
                    for z in vertices: values[z]+=v
                else:
                    lines.append(f'{op} {x+1}'+(f' {y+1}' if op==2 else ''))
                    expected.append(str(sum(values[z] for z in vertices)))
            run(exe,'\n'.join(lines)+'\n','\n'.join(expected))

    def test_hld_deep_tree(self):
        import resource
        import subprocess

        exe = compile_program('hld_deep_tree', printed('code/树上问题/HLD.cpp') + r'''
int main() {
    const int n = 200000;
    HLD h(n);
    for (int v = 2; v <= n; ++v) h.add(v - 1, v);
    for (int root : {1, n, 1}) {
        h.work(root);
        assert(h.dfn == n && h.lca(1, n) == root && h.dist(1, n) == n - 1);
        for (int v = 1; v <= n; ++v) {
            int position = root == 1 ? v : n - v + 1;
            assert(h.in[v] == position && h.dep[v] == position);
            assert(h.top[v] == root && h.siz[v] == n - position + 1);
            h.subtree(v, [&](int l, int r) { assert(l == position && r == n); });
        }
        int length = 0;
        h.path(1, n, [&](int l, int r) { length += r - l + 1; });
        assert(length == n);
    }
}
''')

        def limit_stack():
            resource.setrlimit(resource.RLIMIT_STACK, (8 * 1024**2, 8 * 1024**2))
            resource.setrlimit(resource.RLIMIT_CORE, (0, 0))

        result = subprocess.run([str(exe)], text=True, capture_output=True,
                                timeout=30, preexec_fn=limit_stack)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_maximum_flows_and_cut_tree(self):
        source = printed('code/网络流/Dinic-解.cpp') + printed('code/网络流/预流推进-HLPP.cpp')
        source += printed('chapters/网络流.typ','最小割树-gomory-hu-tree')
        check('flows_and_cut_tree', source + r'''
i64 cutOracle(int n, const vector<tuple<int,int,i64>> &edges, int s, int t) {
    i64 best=LLONG_MAX;
    for(int mask=0;mask<(1<<n);++mask) if((mask>>(s-1)&1)&&!(mask>>(t-1)&1)) {
        i64 value=0;
        for(auto [u,v,w]:edges) if((mask>>(u-1)&1)&&!(mask>>(v-1)&1)) value+=w;
        best=min(best,value);
    }
    return best;
}
int main() {
    mt19937 rng(2342);
    for(int trial=0;trial<350;++trial) {
        int n=2+rng()%6;
        Flow_<i64> dinic(n); PushRelabel<i64> hlpp(n); PushRelabel<int> small(n);
        vector<tuple<int,int,i64>> edges,undirected,doubled;
        for(int u=1;u<=n;++u)for(int v=1;v<=n;++v) if(rng()%4==0) {
            i64 w=rng()%7;
            edges.emplace_back(u,v,w); dinic.add(u,v,w);hlpp.addedge(u,v,w);small.addedge(u,v,w);
            if(u<v) {undirected.emplace_back(u,v,w);doubled.emplace_back(u,v,w);doubled.emplace_back(v,u,w);}
        }
        i64 expected=cutOracle(n,edges,1,n);
        assert(dinic.work(1,n)==expected); assert(dinic.work(1,n)==0);
        assert(hlpp.work(1,n)==expected); assert(small.work(1,n)==expected);
        auto tree=gomoryHu(n,undirected);
        for(int s=1;s<=n;++s) {
            auto dfs=[&](auto &&self,int x,int parent,i64 value)->void{
                if(x!=s) assert(value==cutOracle(n,doubled,s,x));
                for(auto [y,w]:tree[x])if(y!=parent)self(self,y,x,min(value,w));
            }; dfs(dfs,s,0,LLONG_MAX);
        }
    }
    Flow_<i64> d(3);PushRelabel<i64> p(3);
    d.add(1,2,5000000000LL);d.add(2,3,4000000000LL);
    p.addedge(1,2,5000000000LL);p.addedge(2,3,4000000000LL);
    assert(d.work(1,3)==4000000000LL&&p.work(1,3)==4000000000LL);
}
''')
        run(compile_program('gomory_hu_example',printed('code/网络流/Dinic-解.cpp')+
                            printed('chapters/网络流.typ','最小割树-gomory-hu-tree')+
                            printed('chapters/网络流.typ','最小割树-gomory-hu-tree',1)),
            '4 2\n1 2 5\n2 3 7\n3\n1 3\n2 3\n1 4\n','5\n7\n0')

    def test_minimum_cost_flow(self):
        check('minimum_cost_flow',printed('code/网络流/费用流.cpp') + r'''
int main() {
    mt19937 rng(748);
    for(int trial=0;trial<350;++trial) {
        int n=2+rng()%4;
        MinCostFlow f(n);
        vector<tuple<int,int,int,int>> edges;
        for(int u=0;u<n;++u)for(int v=u+1;v<n;++v)if(rng()%3==0) {
            int cap=rng()%3,cost=int(rng()%13)-6;
            edges.emplace_back(u,v,cap,cost);f.add(u,v,cap,cost);
        }
        i64 bestFlow=-1,bestCost=0;
        vector<int> balance(n);
        auto enumerate=[&](auto &&self,int k,i64 cost)->void {
            if(k==(int)edges.size()) {
                for(int x=1;x<n-1;++x)if(balance[x])return;
                i64 value=-balance[0];
                if(value>bestFlow||(value==bestFlow&&cost<bestCost)){bestFlow=value;bestCost=cost;}
                return;
            }
            auto [u,v,cap,w]=edges[k];
            for(int x=0;x<=cap;++x) {balance[u]-=x;balance[v]+=x;self(self,k+1,cost+i64(x)*w);balance[u]+=x;balance[v]-=x;}
        }; enumerate(enumerate,0,0);
        assert(f.flow(0,n-1)==pair(bestFlow,bestCost));
        assert((f.flow(0,n-1)==pair<i64,i64>(0,0)));
    }
    MinCostFlow f(2);
    const i64 weight = (1LL << 56) - 1;
    // 路径费用在约定范围内；流量乘费用在最终相消前会超过 i64。
    f.add(0,1,1000,-weight);f.add(0,1,1000,weight);
    assert((f.flow(0,1)==pair<i64,i64>(2000,0)));
    MinCostFlow extreme(3);extreme.add(0,1,1,-weight);extreme.add(1,2,1,weight-1);
    assert((extreme.flow(0,2)==pair<i64,i64>(1,-1)));
}
''')

    def test_shortest_paths(self):
        bf = 'code/图论/负权图Bellman-ford-算法.cpp'
        sp = 'code/图论/负权图SPFA-算法.cpp'
        nc = 'code/图论/判定图中是否存在负环.cpp'
        check('shortest_paths',printed(bf)+printed(sp)+printed(nc)+
              printed('chapters/图论.typ','多源汇最短路-floyd')+r"""
int main() {
    mt19937 rng(423);
    const i64 inf = 1LL << 60;
    for(int trial=0;trial<300;++trial) {
        int n=1+rng()%6;
        vector<int> potential(n);
        for(int &x:potential)x=int(rng()%21)-10;
        vector<vector<pair<int,i64>>> adj(n);
        vector<tuple<int,int,i64>> edges;
        vector matrix(n,vector<i64>(n,LLONG_MAX));
        for(int u=0;u<n;++u) {
            matrix[u][u]=0;
            for(int v=0;v<n;++v) if(rng()%3==0){
                i64 w=int(rng()%6)+potential[v]-potential[u];
                adj[u].push_back({v,w});edges.emplace_back(u+1,v+1,w);
                matrix[u][v]=min(matrix[u][v],w);
            }
        }
        assert(!hasNegativeCycle(adj));
        floyd(matrix);
        for(int s=0;s<n;++s) {
            vector<optional<i64>> expected(n);
            auto dfs=[&](auto &&self,int x,i64 value,int remaining)->void{
                if(!expected[x]||value<*expected[x])expected[x]=value;
                if(remaining)for(auto [y,w]:adj[x])self(self,y,value+w,remaining-1);
            };
            dfs(dfs,s,0,n-1);
            auto distances = spfa(adj,s);
            assert(!distances.empty());
            for(int v=0;v<n;++v) assert(distances[v]==expected[v].value_or(inf));
            for(int v=0;v<n;++v) assert(matrix[s][v]==expected[v].value_or(LLONG_MAX));
            for(int k=0;k<=3;++k){
                expected.assign(n,nullopt);dfs(dfs,s,0,k);
                auto answer=bellmanFord(n,edges,s+1,k);
                for(int v=0;v<n;++v) assert(answer[v+1]==expected[v].value_or(inf));
            }
        }
    }
    vector<vector<pair<int,i64>>> adj(3);
    vector<i64> d;
    const i64 big = (1LL << 57) - 1;
    adj[1].push_back({2,-big});adj[2].push_back({1,big-1});
    assert(hasNegativeCycle(adj)); d = spfa(adj,0);
    assert((d==vector<i64>{0,inf,inf}));
    assert(spfa(adj,1).empty());
    adj[2].clear();assert(!hasNegativeCycle(adj));
    d = spfa(adj,1); assert(d[2]==-big&&d[0]==inf);
    assert(hasNegativeCycle({{{0,-1}}})&&spfa({{{0,-1}}},0).empty());
    assert(bellmanFord(3,{{2,3,-7}},1,2)[3]==inf);
    assert(bellmanFord(1,{{1,1,-7}},1,3)[1]==-21);
    // 约定范围内的大前缀经负边抵消。
    vector<vector<pair<int,i64>>> prefix(4);
    prefix[0]={{1,big},{2,big}};prefix[1]={{2,big}};prefix[2]={{3,-big}};
    d = spfa(prefix,0); assert(!d.empty());
    assert(d[1]==big&&d[2]==big&&d[3]==0);
    auto bounded=bellmanFord(4,{{1,2,big},{2,3,big},{3,4,-big},{1,3,big}},1,3);
    assert(bounded[4]==0);
    // 第三轮才出现更短前缀，不能在同轮再走第四条边。
    bounded=bellmanFord(6,{{1,2,big},{2,3,big},{3,4,-big},{1,5,0},{5,6,0},{6,3,0}},1,3);
    assert(bounded[3]==0&&bounded[4]==big);
}
""")
        run(compile_program('bf_example',example(bf)),'3 1 2\n2 3 -1\n','0\nN\nN')
        spfa_example = compile_program('spfa_example',example(sp))
        run(spfa_example,'3 1\n2 3 -1\n','0\nN\nN')
        run(spfa_example,'2 2\n1 2 -2\n2 1 1\n','Negative cycle')
        run(compile_program('negative_cycle_example',example(nc)),
            '3 2\n2 3 -4000000000\n3 2 3999999999\n','Yes')


    def test_dijkstra(self):
        path='code/图论/Dijkstra.cpp'
        check('dijkstra',printed(path)+r"""
int main(){
    mt19937 rng(855);
    for(int trial=0;trial<300;++trial){
        int n=1+rng()%8;
        vector<vector<pair<int,i64>>>adj(n);
        for(int x=0;x<n;++x)for(int y=0;y<n;++y)if(rng()%4==0)adj[x].push_back({y,rng()%15});
        for(int s=0;s<n;++s){
            vector<optional<i64>> expected(n);expected[s]=0;
            // Bellman–Ford 的快照递推，不使用堆或贪心。
            for(int k=0;k<n-1;++k){auto old=expected;for(int x=0;x<n;++x)if(old[x])for(auto[y,w]:adj[x]){
                i64 next=*old[x]+w;if(!expected[y]||next<*expected[y])expected[y]=next;
            }}
            auto answer=dijkstra(adj,s);
            for(int v=0;v<n;++v) assert(answer[v]==expected[v].value_or(LLONG_MAX));
        }
    }
    auto answer=dijkstra({{{1,LLONG_MAX-1}},{{2,0}},{}},0);
    assert(answer[1]==LLONG_MAX-1&&answer[2]==LLONG_MAX-1);
    // 非最短候选路径可以超过 i64 上界，不得溢出成负距离。
    answer=dijkstra({{{1,LLONG_MAX-1},{2,7}},{{2,LLONG_MAX}},{}},0);
    assert(answer[1]==LLONG_MAX-1&&answer[2]==7);
    assert(dijkstra({{}},0)==vector<i64>{0});
}
""")
        run(compile_program('dijkstra_example',example(path)),
            '4 3 1\n1 2 5\n1 3 0\n3 2 2\n','0\n2\n0\nN')
