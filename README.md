RS電算(A.D. DEBUG STATION)
====

ここでは主に[赤石鯖](https://www.akaishi-teacher.net/)や、私が運用していたサーバーで使っていたスクリプトを公開してます。

# Update script for BuildTools
Require: **curl** & **jq**(この2つは予めインストールしておいてください)

Bukkit/Spigotを得るためのBuildToolsのアップデートからBuildToolsの実行までサポートするbashスクリプトです。
cronに登録しておけば定期的にアップデートできます。
簡易のチェックをしているので、必要無いときはアップデートやBuildToolsを実行しません。
BuildToolsを強制実行するには引数に`force`と入力します。

```bash
./update-bt.sh force
```
