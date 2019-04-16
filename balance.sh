#!/usr/bin/env sh

two_dec() {
    sed 's/\(\...\).*/\1/'
    return 0
}

exec 2>/dev/null

php_opts="-q"

tf_balance="$(nix tf balance || echo /dev/null)"
trap "rm \"$tf_balance\" 2>/dev/null" 0

nzd_usd=1.46

# https://www.google.com/finance/converter?a=1t&from=NZD&to=USD

while :; do
    out="$(
    echo
    echo -------- upgrade this with a graph. sleep = 60
    echo

    out="$(php $php_opts $HOME/source/git/rest/php/gate.php)"

    bal="$(p "$out" | sed -n '1p' | two_dec)"
    rate="$(p "$out" | sed -n '2p' | two_dec)"
    rate_btc="$(p "$out" | sed -n '3p')"
    usd="$(p "$out" | sed -n '4p' | two_dec)"
    nzd="$(lit "$usd * $nzd_usd" | bc)"
    # nzd

    echo "NAS: $bal"
    echo "rate: \$$rate, B$rate_btc"
    echo "USD: \$$usd"
    echo "NZD: \$$nzd"
    elinks-dump "https://coinmarketcap.com/currencies/nebulas-token/" | scrape 'Rank [0-9]+'
    echo

    bal="$(p "$out" | sed -n '5p' | two_dec)"
    rate="$(p "$out" | sed -n '6p' | two_dec)"
    rate_btc="$(p "$out" | sed -n '7p')"
    usd="$(p "$out" | sed -n '8p' | two_dec)"

    echo "GAS: $bal"
    echo "rate: \$$rate, B$rate_btc"
    echo "USD: \$$usd"
    elinks-dump "https://www.coingecko.com/en/coins/gas" | scrape 'Rank #[0-9]+'
    echo


    btc_usd="$(p "$out" | sed -n '9p' | two_dec)"
    echo "BTC: $btc_usd"
    btc_nzd="$(lit "$btc_usd * $nzd_usd" | bc)"
    echo "NZD: $btc_nzd"
    echo


    out="$(php $php_opts $HOME/notes2018/ws/bitfinex/bitfinex-api-php/get_balance.php)"

    bal="$(p "$out" | sed -n '1p' | two_dec)"
    rate="$(p "$out" | sed -n '2p' | two_dec)"
    usd="$(p "$out" | sed -n '3p' | two_dec)"

    echo "AGI: $bal"
    echo "rate: \$$rate"
    echo "USD: \$$usd"
    elinks-dump "https://www.coingecko.com/en/coins/singularitynet" | scrape 'Rank #[0-9]+'
    echo




    bal="$(p "$out" | sed -n '4p' | two_dec)"
    rate="$(p "$out" | sed -n '5p' | two_dec)"
    usd="$(p "$out" | sed -n '6p' | two_dec)"

    echo "ZRX: $bal"
    echo "rate: \$$rate"
    echo "USD: \$$usd"

    echo




    bal="$(p "$out" | sed -n '7p' | two_dec)"
    rate="$(p "$out" | sed -n '8p' | two_dec)"
    usd="$(p "$out" | sed -n '9p' | two_dec)"

    echo "LRC: $bal"
    echo "rate: \$$rate"
    echo "USD: \$$usd"

    echo
    )"
    lit "$out" | s indent 1 | ts | rosie match all.things >> "$tf_balance"
    sleep 60
done &

less -rS +F "$tf_balance"
