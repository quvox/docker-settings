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
まず最初の一回は、knowledgeをbuildする必要がある。
```
cd build/knowledge
docker build -t knowledge:1.6.0 .
```

残りの作業は全て、docker-compose.ymlファイルが置かれているディレクトリで行う。

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
 - サービスごとのDockerfileが格納されている。
 - それぞれのサブディレクトリの中でdocker buildすればよい。
- data/
 - 各サービスがデータ格納用に使う。(自動生成されるので最初は存在しない)
 - 基本的にはサービスごとにData Volume Containerを作って、マウントしている。
 - data/全体をバックアップすればいい。


