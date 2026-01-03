# docker4asterisk

Qiitaに掲載した記事 [内線電話 + 050plus 作業メモ](https://qiita.com/mbamba/items/abf90358d9b27b5b7993) をDockerfileにしました。

```
$ docker --version
Docker version 29.1.3, build f52814d
```

このDockerで動作確認しました。

## 実行

### docker build

普通にビルドします。

```
docker build -t asterisk .
```


### docker run

おまじないが一部入っていますので、適宜直してください

```
docker run \
    -it \
    -e DISPLAY=${DISPLAY} \
    -v $HOME/.Xauthority:/home/ubuntu/.Xauthority:rw \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    --network myVlan \
    --ip 192.168.0.110 \
    --name asterisk \
    --hostname asterisk_srv \
    --rm \
    --tmpfs /tmp:exec \
    asterisk
```

## その他

### ネットワーク

試した環境は、br0が存在してる環境です。
```
$ sudo brctl show 
bridge name	bridge id		STP enabled	interfaces
br0		8000.XXXXXXXXXXXX	no		enp1s0
docker0		8000.YYYYYYYYYYYY	no
```

これに対して、次のコマンドを投入して整備
```
$ docker network create \
  --driver=macvlan \
  --subnet=192.168.0.0/24 \
  --gateway=192.168.0.1 \
  -o parent=br0 \
  myVlan
```


### 雑記
**イマイチなところ**
- /etc/asterisk はノーメンテです。ローカルにetc-asterisk.tar.gzを用意していれば、Dockerfile実行中に、展開します。用意されない場合は動きません。既存の動作している環境からtar.gzされることを期待しています
- 余計なモジュールをaptしているかもしれないです


