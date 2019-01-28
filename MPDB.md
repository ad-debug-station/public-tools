【赤石鯖】スタッフ・管理者向け 雑なMPDBマニュアル
----
# MPDBってなあに？
赤石鯖で「データを同期してます」とかしてるプラグインの事。超大黒柱マジ卍。
MPDBは **M**ySQL **P**layer **D**ata **B**ridgeの略。

# コマンド情報を提供する理由
プレイヤーが事故（故意では無い事）によって全てのアイテムを失った際に使える便利な機能があるため。
## 注意事項
とても強力なプラグインです。
全ユーザー、対象ユーザーがオフラインでもインベントリ情報を書き換える（ユーザーデータも一掃可）ことが可能。

なので、必要の無いときは使用しない。（ __プライバシー__ 的な事を言ってるぞ）

# コマンド♥
全部掲載すると面倒なのでしません。必要な部分だけ。

* `/mpdb inv <name>` 対象ユーザーのインベントリをオープン・編集します。
* `/mpdb armor <name>` 対象ユーザーの装備品をオープン・編集します。
* `/mpdb end <name>` 対象ユーザーのエンダーチェストをオープン・編集します。
* `/mpdb getXp <name> ` 対象ユーザーの経験値を表示。
* `/mpdb setXp <name> <exp> ` 対象ユーザーの経験値を設定。
* `/mpdb addXp <name> <exp>`  対象ユーザーの経験値を追加。

EOF