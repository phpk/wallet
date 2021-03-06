require! {
    \prelude-ls : { filter, reverse, head, foldl, find }
    \./install-plugin.ls : { get-install-list }
    \./get-primary-coin.ls
}
common =
    * require \../web3t/plugins/gobyte-topup.ls
    * require \../web3t/plugins/trycrypto-topup.ls
    ...
verify-fields = (t)->
    return no if t.type isnt \topup
    return no if t.enabled isnt yes
    return no if typeof! t.topup-coins-by-mask isnt \String
    return no if typeof! t.networks isnt \String
    return no if typeof! t.token isnt \String
    return no if typeof! t.image isnt \String
    return no if typeof! t.address isnt \String
    return yes
get-methods = ->
    base =
        common
            |> filter verify-fields
    installed =
        get-install-list! |> filter (.type is \topup)
    installed ++ base
support = ({ token, network }, { topup-coins-by-mask, networks })-->
    return no  if networks.split(', ').index-of(network) is -1
    return yes if topup-coins-by-mask is '*'
    return yes if topup-coins-by-mask.split(', ').index-of(token) > -1
    return no
replace = (params)-> (str, key)->
    mask = "{" + key + "}"
    str.replace mask, params[key]
put = (params, address)-->
    keys = Object.keys params
    return address if keys.length is 0
    keys 
        |> foldl replace(params), address
filter-by-importance = (store)-> (arr, item)->
    coin = get-primary-coin store
    all = arr ++ [item]
    return all if not coin?branding?topup?
    #coin.branding.topup
    important = 
        all |> find (.token is coin?branding?topup)
    return [important] if important?
    return all
export get-topup-address = (store, { token, network, address })->
    method =
        get-methods!
            |> foldl filter-by-importance(store), []
            |> filter support { token, network } 
            |> reverse
            |> head
    return null if not method?
    method.address |> put { token, address, network }