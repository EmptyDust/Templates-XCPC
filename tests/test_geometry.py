import unittest
import re
from support import ROOT, check, printed


def plane_source():
    return (printed('code/二维几何/预置函数.cpp') + printed('code/二维几何/点线封装.cpp') +
            printed('chapters/二维几何.typ','叉乘') + printed('chapters/二维几何.typ','点乘') +
            printed('chapters/二维几何.typ','点是否在线段上') +
            printed('chapters/二维几何.typ','两直线相交交点'))


class GeometryTests(unittest.TestCase):
    def test_printed_alias_declaration(self):
        chapter = (ROOT / 'chapters/二维几何.typ').read_text()
        declaration = re.search(r'`(template<typename T> using Pt[^`]+;)`', chapter).group(1)
        source = printed('code/二维几何/预置函数.cpp') + printed('code/二维几何/点线封装.cpp')
        check('geometry_alias', source + declaration + r'''
int main() { static_assert(is_same_v<Pt<i64>, Point<i64>>); }
''')

    def test_planar_intersections_and_composition(self):
        source=plane_source()
        for anchor in ['两线段是否相交及交点','点是否在向量直线左侧','两点是否在直线同侧异侧',
                       '两直线是否平行垂直相同','向量旋转','线段的中垂线']:
            source+=printed('chapters/二维几何.typ',anchor)
        source+=printed('chapters/二维几何.typ','两线段是否相交及交点',1)
        source+=printed('code/二维几何/欧几里得距离公式.cpp')
        source+=printed('chapters/二维几何.typ','点到直线的最近距离与最近点')
        source+=printed('chapters/二维几何.typ','点到直线的最近距离与最近点',1)
        source+=printed('chapters/二维几何.typ','点到线段的最近距离与最近点')
        source+=printed('chapters/二维几何.typ','三角形外心')
        source+=printed('chapters/二维几何.typ','浮点数计算直线的斜率')
        source+=printed('chapters/多边形相关.typ','判断四个点能否组成矩形正方形')
        check('planar_geometry',source+r'''
int main(){
    auto orientation=[](Pi a,Pi b,Pi c){return (b.x-a.x)*(c.y-a.y)-(b.y-a.y)*(c.x-a.x);};
    auto on=[&](Pi a,Pi b,Pi p){return orientation(a,b,p)==0&&min(a.x,b.x)<=p.x&&p.x<=max(a.x,b.x)&&min(a.y,b.y)<=p.y&&p.y<=max(a.y,b.y);};
    vector<Pi> points;for(int x=-2;x<=2;++x)for(int y=-2;y<=2;++y)points.emplace_back(x,y);
    for(Pi a:points)for(Pi b:points)for(Pi c:points)for(Pi d:points){
        int x=orientation(a,b,c),y=orientation(a,b,d),u=orientation(c,d,a),v=orientation(c,d,b);
        bool strict=x*y<0&&u*v<0;
        bool expected=strict||on(a,b,c)||on(a,b,d)||on(c,d,a)||on(c,d,b);
        assert(segmentsIntersect(Line{a,b},Line{c,d})==expected);
        auto [kind,p,q]=segmentIntersection(Ld{a,b},Ld{c,d});
        assert(bool(kind)==expected);assert((kind==1)==strict);
        if(kind){assert(pointOnSegment(p,Ld{a,b})&&pointOnSegment(p,Ld{c,d}));assert(pointOnSegment(q,Ld{a,b})&&pointOnSegment(q,Ld{c,d}));}
        if(kind==2)assert(p!=q);
        if(kind==3)assert(p==q);
    }
    assert(pointOnSegmentEx(Pi{1,0},Line{Pi{0,0},Pi{2,0}}));
    assert(!pointOnSegmentEx(Pi{0,0},Line{Pi{0,0},Pi{0,0}}));
    Line<i64> a{{-1000000000,-1000000000},{1000000000,1000000000}};
    Line<i64> b{{-1000000000,1000000000},{1000000000,-1000000000}};
    assert(segmentsIntersect(a,b));
    assert(pointNotOnLineSide(b.a,b.b,a)&&!pointOnLineSide(b.a,b.b,a));
    assert(lineVertical(a,b)&&!lineParallel(a,b)&&same(a,a));
    assert(pointOnLineLeft(Pi{0,1},Line{Pi{0,0},Pi{1,0}}));
    auto middle=midSegment({{0,0},{1,0}});assert(equal(middle.a.x,0.5L));
    // 排序不能用 EPS：接近的三个横坐标仍须满足严格弱序。
    vector<Pd> close{{0,2},{EPS*0.75L,1},{EPS*1.5L,0}};
    assert(close[0]<close[1]&&close[1]<close[2]&&close[0]<close[2]);
    assert(equal(LLONG_MIN,LLONG_MIN)&&!equal(LLONG_MIN,LLONG_MAX));
    assert(equal(slope(Pi{0,0},Pi{2,1}),0.5L));
    assert(equal(disPointToLine(Pi{1,1},Line{Pi{0,0},Pi{2,0}}),1.0L));
    assert((pointToSegment({1,2},{{0,0},{0,0}}).first==Pd{0,0}));
    assert((center1({0,0},{1,0},{0,1})==Pd{0.5L,0.5L}));
    assert(isSquare<int>({{0,0},{2,0},{0,1},{2,1}})==1);
    assert(isSquare<int>({{0,0},{2,0},{0,2},{2,2}})==2);
}
''')

    def test_spatial_intersections(self):
        source=printed('code/二维几何/预置函数.cpp')+printed('code/三维几何及常见例题/点线面封装.cpp')
        source+=printed('code/三维几何及常见例题/其他函数.cpp')
        source+=printed('code/三维几何及常见例题/空间点是否在线段上.cpp')
        source+=printed('code/三维几何及常见例题/空间两线段是否相交.cpp')
        source+=printed('code/三维几何及常见例题/直线与平面是否相交及交点.cpp')
        source+=printed('chapters/三维几何及常见例题.typ','空间两直线是否相交及交点')
        source+=printed('chapters/三维几何及常见例题.typ','两平面是否相交及交线')
        check('spatial_geometry',source+r'''
int main(){
    auto near=[](P3 a,P3 b){return dis(a,b)<1e-7L;};
    assert(pointOnSegmentEx({1,0,0},{{0,0,0},{2,0,0}}));
    assert(pointOnSegmentEx({0,1,0},{{0,0,0},{0,2,0}}));
    assert(pointOnSegmentEx({0,0,1},{{0,0,0},{0,0,2}}));
    assert(!segmentIntersection1({{0,0,0},{1,0,0}},{{2,0,0},{3,0,0}}));
    assert(!segmentIntersection({{0,0,0},{1,0,0}},{{2,0,0},{3,0,0}}));
    assert(segmentIntersection({{0,0,0},{2,0,0}},{{1,0,0},{3,0,0}}));
    assert(!segmentIntersection1({{0,0,0},{2,0,0}},{{1,0,0},{3,0,0}}));
    assert(segmentIntersection({{1,0,0},{1,0,0}},{{0,0,0},{2,0,0}}));
    assert(!segmentIntersection({{0,0,0},{1,0,0}},{{0,0,1},{0,1,1}}));
    auto axes=lineIntersection({{0,0,0},{1,0,0}},{{0,0,0},{0,1,0}});
    assert(axes.first&&near(axes.second,{0,0,0}));
    Plane z{{0,0,0},{1,0,0},{0,1,0}},x{{0,0,0},{0,1,1},{0,-1,1}};
    auto planes=planeIntersection(z,x);
    assert(planes.first&&dis(planes.second.a,planes.second.b)>EPS);
    assert(near(planes.second.a,{0,0,0})&&abs(planes.second.b.x)<EPS&&abs(planes.second.b.z)<EPS);
    assert(!planeIntersection(z,z).first);
    assert(!linePlaneCross({{0,0,0},{1,0,0}},z).first);
    assert(!linePlaneCross({{0,0,0},{0,0,1}},{{0,0,0},{1,0,0},{2,0,0}}).first);
    mt19937 rng(556);
    auto point=[&](){return P3{ld(int(rng()%15)-7),ld(int(rng()%15)-7),ld(int(rng()%15)-7)};};
    for(int test=0;test<2000;++test){
        P3 p=point(),u=point(),v=point();
        if(len(crossEx(u,v))<EPS)continue;
        auto result=lineIntersection({p-u,p+u},{p-v,p+v});
        assert(result.first&&near(result.second,p));
        assert(segmentIntersection1({p-u,p+u},{p-v,p+v}));
        assert(!segmentIntersection({p+u,p+u*2},{p-v,p+v}));
        Plane a{p,p+u,p+v};P3 w=point();Plane b{p,p+u,p+w};
        if(len(crossEx(getVec(a),getVec(b)))<EPS)continue;
        auto cut=planeIntersection(a,b);assert(cut.first&&dis(cut.second.a,cut.second.b)>EPS);
        for(P3 q:{cut.second.a,cut.second.b}){
            assert(abs(dot(getVec(a),q-a.u))<1e-6L);
            assert(abs(dot(getVec(b),q-b.u))<1e-6L);
        }
        P3 normal=getVec(a);
        auto planePoint=linePlaneCross({p-normal,p+normal},a);
        assert(planePoint.first&&near(planePoint.second,p));
    }
}
''')

    def test_half_plane_intersection(self):
        check('half_planes',plane_source()+printed('chapters/多边形相关.typ','半平面交')+r'''
ld area(const vector<Pd>&polygon){
    ld result=0;
    for(int i=0;i<polygon.size();++i)result+=cross(polygon[i],polygon[(i+1)%polygon.size()]);
    return abs(result)/2;
}
int main(){
    // 已知边界 [-10,10]^2 本来就是题目约束；逐线裁剪作独立参考。
    vector<Pd> square{{-10,-10},{10,-10},{10,10},{-10,10}};
    vector<Ld> bound;
    for(int i=0;i<4;++i)bound.push_back({square[i],square[(i+1)%4]});
    mt19937 rng(678);
    for(int trial=0;trial<600;++trial){
        auto lines=bound;auto clipped=square;
        for(int j=0,count=rng()%15;j<count;++j){
            Pd a{ld(int(rng()%31)-15),ld(int(rng()%31)-15)};
            Pd direction{ld(int(rng()%7)-3),ld(int(rng()%7)-3)};
            if(direction==Pd{})continue;
            Ld line{a,a+direction};lines.push_back(line);
            if(rng()%3==0)lines.push_back(line);
            vector<Pd> next;
            for(int i=0;i<clipped.size();++i){
                Pd p=clipped[i],q=clipped[(i+1)%clipped.size()];
                ld x=cross(direction,p-a),y=cross(direction,q-a);
                if(x>=-EPS)next.push_back(p);
                if((x>EPS&&y<-EPS)||(x<-EPS&&y>EPS))next.push_back(p+(q-p)*(x/(x-y)));
            }
            clipped=move(next);
        }
        shuffle(lines.begin(),lines.end(),rng);
        auto result=halfcut(lines);
        assert(abs(area(result)-area(clipped))<1e-6L);
        for(Pd p:result){assert(isfinite(p.x)&&isfinite(p.y));for(Ld l:lines)assert(cross(l.b-l.a,p-l.a)>-1e-6L);}
    }
    auto duplicate=bound;duplicate.insert(duplicate.end(),bound.begin(),bound.end());
    assert(abs(area(halfcut(duplicate))-400)<EPS);
    auto shortDirection=bound;shortDirection[0].b=shortDirection[0].a+Pd{0.0001L,0};
    assert(abs(area(halfcut(shortDirection))-400)<EPS);
    auto line=bound;line.push_back({{0,0},{0,1}});line.push_back({{0,1},{0,0}});
    assert(halfcut(line).empty());
    auto empty=bound;empty.push_back({{0,11},{1,11}});assert(halfcut(empty).empty());
}
''')
