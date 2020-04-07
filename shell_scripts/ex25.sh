#！/bin/bash
# loancalc -- 根据贷款金额、利率和贷款期限（年），计算每笔付款金额

# 公式为：M = P * ( J / (1- (1+J) ^ -N))，
# 其中， P = 带宽金额， J = 月利率，N = 贷款期限（以月为单位）。

# 用户一般要输入P、I（年利率）以及L（年数）。

. ../1/library.sh # 引入脚本library

if [ $# -ne 3 ] ; then
    echo "Usage: $0 principal interest loan-duration-years" >&2
    exit 1
fi

P=$1
I=$2
L=$3
J="$(scriptbc -p 8 $I / \( 12 \* 100 \) )"
N="$(( $L * 12 ))"
M="$(scriptbc -p 8 $P \* \( $J / \(1 - \(1 + $J\) \^ - $N\) \) )"

# 对金额略做美化处理：
dollars="$(echo $M | cut -d. -f1)"
cents="$(echo $M | cut -d. -f2 | cut -c1-2)"

cat << EOF
A $L-year loan at $I% interest with a principal amount of $(nicenumber $P 1 )
results in a payment of \$$dollars.$cents each month for the duration of
the loan ($N payments).
EOF

exit 0