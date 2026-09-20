import random
import unittest
from support import check, compile_program, printed, run


class RangeTests(unittest.TestCase):
    def test_max_bit(self):
        check('max_bit',printed('chapters/数据结构A.typ','最值查询扩展常规区间最值查询单点赋值')+r'''
int main(){
    mt19937 rng(555);
    for(int n=1;n<70;++n){
        vector<i64> a(n+1,LLONG_MIN);BIT<i64> bit(n,a);
        const auto &view=bit;
        assert(view.getMax(1,n)==LLONG_MIN);
        for(int q=0;q<300;++q){
            int x=1+rng()%n;i64 value=-i64(rng())-3000000000LL;
            a[x]=max(a[x],value);bit.update(x,value);
            int l=1+rng()%n,r=1+rng()%n;if(l>r)swap(l,r);
            assert(view.getMax(l,r)==*max_element(a.begin()+l,a.begin()+r+1));
        }
    }
}
''')

    def test_lazy_construction_reinitialization_and_search(self):
        check('lazy_initialization',printed('chapters/数据结构A.typ','lazyinfotag-线段树')+r'''
int main() {
    using Tree = LazySegmentTree<Info, Tag>;
    static_assert(!is_constructible_v<Tree, int>);
    Tree tree(3, Info{0, 1});
    tree.rangeApply(0, 3, Tag{2});
    assert(tree.rangeQuery(0, 3).sum == 6);
    assert(tree.rangeQuery(0, 3).len == 3);

    tree.init(5, Info{1, 1});
    assert(tree.rangeQuery(0, 5).sum == 5);
    for (int i = 0; i < 5; ++i) assert(tree.rangeQuery(i, i + 1).sum == 1);

    const vector<Info> values{{0, 1}, {3, 1}, {0, 1}, {4, 1}};
    tree.init(values);
    struct Positive {
        int calls = 0;
        bool operator()(const Info &v) {
            ++calls;
            return v.sum > 0;
        }
    } positive;
    assert(tree.findFirst(0, 4, positive) == 1);
    assert(tree.findLast(0, 4, positive) == 3);
    assert(positive.calls > 0);
    assert(tree.findFirst(2, 3, positive) == -1);
    assert(tree.findLast(1, 1, positive) == -1);

    tree.rangeApply(0, 4, Tag{2});
    tree.modify(1, Info{0, 1});
    assert(tree.rangeQuery(0, 4).sum == 10);
    assert(tree.findFirst(1, 4, [](Info v) { return v.sum > 0; }) == 2);
    tree.init(2, Info{0, 1});
    assert(tree.rangeQuery(0, 2).sum == 0);
    assert(tree.findLast(0, 2, positive) == -1);
}
''')

    def test_lazy_assignment_clears_history(self):
        block=printed('chapters/数据结构A.typ','lazyinfotag-线段树')
        check('lazy_assignment',block+r'''
int main(){
    LazySegmentTree<Info,Tag> tree(vector<Info>{{0,1}});
    tree.rangeApply(0,1,Tag{LLONG_MAX});tree.modify(0,Info{0,1});tree.rangeApply(0,1,Tag{1});
    assert(tree.rangeQuery(0,1).sum==1);
}
''')
        exe=compile_program('lazy_example',block+printed('chapters/数据结构A.typ','lazyinfotag-线段树',1))
        rng=random.Random(399)
        for n in [1,2,15,37]:
            values=[rng.randrange(-100,100) for _ in range(n)]
            lines=[f'{n} 250',' '.join(map(str,values))];expected=[]
            for _ in range(250):
                op=rng.randrange(1,4);l=rng.randrange(n);r=rng.randrange(l+1,n+1);x=rng.randrange(-10**10,10**10)
                if op==1:
                    lines.append(f'1 {l} {r} {x}')
                    for p in range(l,r):values[p]+=x
                elif op==2:lines.append(f'2 {l} {r}');expected.append(str(sum(values[l:r])))
                else:lines.append(f'3 {l} {x}');values[l]=x
            run(exe,'\n'.join(lines)+'\n','\n'.join(expected))

    def test_pbds_extrema_and_rebuild(self):
        check('pbds_extrema',printed('chapters/数据结构A.typ','线段树套平衡树')+r'''
int main(){
    SegmentTree<Info> tree;
    const auto &view=tree;
    vector<int>a{INT_MIN,INT_MAX};tree.build(a);
    assert(view.query_pred(0,2,0)==INT_MIN&&view.query_succ(0,2,0)==INT_MAX);
    assert(view.query_pred(0,2,INT_MIN)==-inf&&view.query_succ(0,2,INT_MAX)==inf);
    assert(view.query_pred(0,1,INT_MAX)==INT_MIN&&view.query_succ(1,2,INT_MIN)==INT_MAX);
    mt19937 rng(734);
    for(int trial=0;trial<80;++trial){
        a.resize(1+rng()%30);for(int &x:a)x=int(rng()%21)-10;
        tree.build(a);
        for(int query=0;query<150;++query){
            int pos=rng()%a.size(),v=int(rng()%31)-15;
            tree.update(pos,a[pos],v);a[pos]=v;
            int l=rng()%a.size(),r=l+1+rng()%(a.size()-l),k=int(rng()%31)-15,count=0;
            optional<int> pred,succ;
            for(int i=l;i<r;++i){
                if(a[i]<k){++count;if(!pred||a[i]>*pred)pred=a[i];}
                if(a[i]>k&&(!succ||a[i]<*succ))succ=a[i];
            }
            assert(view.query_rank_count(l,r,k)==count);
            assert(view.query_pred(l,r,k)==(pred?i64(*pred):-inf));
            assert(view.query_succ(l,r,k)==(succ?i64(*succ):inf));
        }
    }
}
''')
