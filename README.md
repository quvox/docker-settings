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

wordpressだけ立ち上げたい時
```
docker-compose up -d wordpress
```

# ディレクトリ構成
- build/
 - サービスごとのDockerfileなどが格納されている。
 - それぞれのサブディレクトリの中でdocker buildすればよい。
- data/
 - 各サービスがデータ格納用に使う。(自動生成されるので最初は存在しない)
 - 基本的にはサービスごとにData Volume Containerを作って、マウントしている。
 - data/全体をバックアップすればいい。

