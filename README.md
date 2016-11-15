docker環境
====
# サービス一覧
- http proxy
 - nginx-proxy
 - Let's Encrypt
 - http://sig9.hatenablog.com/entry/2016/07/06/230000

- gitbucket
- knowledge
- wordpress
- mysql

# 起動方法
環境設定
|環境変数|説明|
|HOSTNAME_GIT|gitbucketにアクセスするためのvirtual host name<br>(reverse proxyで利用)|
|HOSTNAME_WORDPRESS|wordpressにアクセスするためのvirtual host name<br>(reverse proxyで利用)|
|HOSTNAME_KNOWLEDGE|knowledgeにアクセスするためのvirtual host name<br>(reverse proxyで利用)|
|CERT_HOST|マルチドメイン証明書に含めるホスト名|
|LETSENCRYPT_EMAIL|Let's Encryptで利用するe-mailアドレス|

## 初回起動のみやるべきこと

最初の一回は、証明書を取得し、knowledgeをbuildする必要がある。

### 証明書取得
```
sh ./init_certs.sh
```
keyをsaveしたというログが出るまでじっと待つ。でたら、Ctrl-Cで停止してから、
```
sh ./init_certs.sh down
```
とする。

*うまくいかない時がある。原因不明*

### knowledgeのbuild
```
cd build/knowledge
docker build -t knowledge:1.6.0 .
```

残りの作業は全て、docker-compose.ymlファイルが置かれているディレクトリで行う。

## 起動

全部立ち上げたい時
```
docker-compose up -d
```

gitbucketだけ立ち上げたい時
```
docker-compose up -d gitbucket
```

nginx-proxyとwordpressだけ立ち上げたい時
```
docker-compose up -d nginx-proxy wordpress
```

# ディレクトリ構成
- build/
 - サービスごとのDockerfileなどが格納されている。
 - それぞれのサブディレクトリの中でdocker buildすればよい。
- data/
 - 各サービスがデータ格納用に使う。(自動生成されるので最初は存在しない)
 - 基本的にはサービスごとにData Volume Containerを作って、マウントしている。
 - data/全体をバックアップすればいい。

# nginx-proxyの設定方法について
nginx-proxyでは、/etc/nginx/conf.d/default.conf (およびmy-proxy.conf)で基本的な設定がなされている（このファイルやディレクトリはマウントされていない）。個別のvirtual hostに対して設定したい場合は、data/nginx-proxy/vhost.d/の下に設定ファイルを置けばよい。そうすることによって、/etc/nginx/conf.d/default.confの中の一部が変更される（またはincludeされる）。例えばhostA.example.comというvirtual hostの場合を書く。

### vhost.d/hostA.example.com_location というファイルを置いた場合
このファイルの中身は、/etc/nginx/conf.d/default.conf内のhostA.example.comに関する情報の、locationディレクティブ内にincludeで展開される。つまり、locationディレクティブの中に書く内容だけを直接記述すれば良い。例えば、

```
satisfy any;
allow 192.168.0.0/16;
deny all;
auth\_basic "basic authentication";
auth\_basic\_user\_file /etc/nginx/htpasswd/SOMEFILE
```
と書くと、hostA.example.comに対して192.168.0.0/16からアクセスされたときは素通り、それ以外のIPからアクセスされたときは、Basic認証がかかる。なおその際の認証情報は、/etc/nginx/htpasswd/SOMEFILEに格納されるが、これはdata/nginx-proxy/htpasswd/ にマウントされているので、そこでhtpasswdを使ってパスワードファイルを作れば良い（containerに入る必要なし）。

### data/nginx-proxy/htpasswd/hostA.example.com というファイルを置いた場合
このファイルはhtpasswdで作成されたパスワードファイルでなければならない。data/nginx-proxy/htpasswd/の下にvirtual host名と同名のファイルを置いた場合、そのホスト名でのアクセスにはすべてBasic認証が適用される。

したがって、前項で`auth\_basic\_user\_file /etc/nginx/htpasswd/SOMEFILE`という記述をしていたが、このSOMEFILEをhostA.example.comというホスト名と同名ｎファイルにしてしまうと、全部にBasic認証がかかってしまい、意図しない動作となる。

### 参考
https://github.com/jwilder/nginx-proxy


# その他注意点
- Ubuntuを使っていると、NetworkManagerがdns-masqを勝手に起動しているため、dnsサーバ(bind9)を立ち上げようとするとport 53/udpがAddress already in useになって起動できない。
 - dns-masqが立ち上がらないようにすれば良い。（/etc/NetworkManager/NetworkManager.confの`dns=dnsmasq`の行をコメントアウト）
  - http://www.lighthouse-w5.com/index.php/25-linux/62-ubuntu-dnsmasq.html
- gitbucketでsshを使うときは、*必ず*urlの指定を*ssh://user@host/group/repo.git*の形で指定しなければならない。.ssh/configでショートカット名を設定していても、ssh://user@host/の形を必ず守ること！
 - そうしないと、git-receive-packやgit-upload-packのエラーが出てしまう。
