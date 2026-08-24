#include <bits/stdc++.h>
using namespace std;
typedef long long i64;
typedef long long ll;
typedef long long LL;
typedef long double ld;
typedef unsigned long long u64;
const int MOD = 998244353;
const int mod = 1000000007;
const int N = 1000005;
const int M = 2000005;
const double eps = 1e-8;
const double PI = acos(-1.0);

// @book-begin
#include<bits/stdc++.h>
using namespace std;
map<char, int> mp;  //将字符转化为数字
map<int, char> mp2;  //将数字转化为字符
int main(){
    for(int i = 0; i < 10; i++) mp[(char)i + 48] = i, mp2[i] = (char)i + 48;
    for(int i = 10; i < 36; i++) mp[(char)i + 55] = i, mp2[i] = (char)i + 55;
    for(int i = 36; i < 62; i++) mp[(char)i + 61] = i, mp2[i] = (char)i + 61;

    int tt = 1, a, b; cin >> tt;
    while(tt--){
        string s, sh;
        vector<int> nums, ans;
        cin >> a >> b >> s;
        for(auto c : s) nums.push_back(mp[c]);
        reverse(nums.begin(), nums.end());
        while(nums.size()){  //短除法，将整个大数一直除 b ，取余数
            int remainder = 0;
            for(int i = nums.size() - 1; ~i; i--){
                nums[i] += remainder * a;
                remainder = nums[i] % b;
                nums[i] /= b;
            }
            ans.push_back(remainder);  //得到余数
            while(nums.size() && nums.back() == 0) nums.pop_back();  //去掉前导 0
        }
        reverse(ans.begin(), ans.end());
        for(int i : ans) sh += mp2[i];
        cout << a << ' ' << s << endl;
        cout << b << ' ' << sh << endl << endl;
    }
    return 0;
}
// @book-end
