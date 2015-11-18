ansible-ruby-devs
====================
[![Circle CI](https://circleci.com/gh/chroju/ansible-ruby-devs.svg?style=shield)](https://circleci.com/gh/chroju/ansible-ruby-devs)

What is this ?
----------
ansibleの個人用Playbooksです。主にRubyとNode.jsを用いた開発用途に使えるものとしています。

```
├── Dockerfile
├── README.md
├── ansible
│   ├── ansible.cfg
│   ├── authorized_keys.j2
│   ├── ci_hosts
│   ├── ci_site.yml
│   ├── group_vars
│   ├── iptables.j2
│   ├── roles
│   ├── site.yml
│   └── spec
└── circle.yml
```

* Circle.CIを使用し、Serverspecで自動的にテストを実行する構成としています。
* 処理順序としてはDockerfileを元にCircle.CI上で新規コンテナを起動し、ansibleフォルダ配下をマウントさせた上で、コンテナ内のローカルで`ansible-playbook`と`rake spec`を実行させています。
* 以下のファイルはCI用に配置している一時ファイルであり、productionへのデプロイには使用しません。
  * ansible/authorized_keys.j2
  * ansible/ci_hosts
  * ansible/ci_site.yml
  * ansible/iptables.j2
* CIではServerspecによるテストまでを実行するものとし、デプロイの自動実行は組み入れていません。


Ansible
----------

```
ansible                
├── ansible.cfg        
├── authorized_keys.j2 
├── ci_hosts           
├── ci_site.yml        
├── group_vars         
│   ├── ci.yml         
│   └── dev.yml        
├── iptables.j2        
├── roles              
│   ├── atfirst        
│   │   └── tasks      
│   ├── common         
│   │   ├── handlers   
│   │   ├── tasks      
│   │   └── templates  
│   ├── develop        
│   │   └── tasks      
│   ├── nginx          
│   │   └── tasks      
│   ├── postgres       
│   │   └── tasks      
│   └── ruby           
│       └── tasks      
├── site.yml           
└── spec
```

* `sudo` 実行可能な `develop` ユーザーでの実行を前提としています（TODO: 同ユーザーの作成用ロールとして `atfirst` を設けているが未実装）。
* `host_vars` は使用しません。
* `private_vars` フォルダを読み込める設定としています。秘匿性の高い変数は `private_vars` 内で定義することで、 `.gitignore` によりバージョン管理からは除外されます。


Serverspec
----------
* 上述の通りローカル実行します。
* `properties.yml` に記載された変数を読み込みます。
  cf: [Serverspec - Advanced Tips](http://serverspec.org/advanced_tips.html)


Dockerfile
----------
* Circle.CI上で `build` し、ansible及びServerspecをテスト実行することを目的としています。
* CIに必要とされる処理のみを実行しています。


circle.yml
----------
Dockerコンテナの起動と、ansible及びServerspecの実行を制御します。

Dockerコンテナはビルド完了後は `cache_directories` に `save` し、二度目の実行以降は `load` 可能とすることで、実行するたびにビルドを必要とせず、処理時間を短縮しています。

```yaml:circle.yml
dependencies:
  pre:
    - if [[ -e ~/docker/docker_ansible_image.tar ]]; then docker load --input ~/docker/docker_ansible_image.tar ;fi
    - docker build -t centos_ansible /home/ubuntu/ansible/ 
    - mkdir -p ~/docker 
    - docker save -o ~/docker/docker_ansible_image.tar centos_ansible

  cache_directories:
    - "~/docker"
```

ansibleとServerspecは必要ファイルをすべて `docker run` を行う際にコンテナ内へマウントさせ、そのまま `docker run` 時の実行コマンドとしてローカルで処理しています。従ってテスト用コマンドは `docker run` のみです。

```yaml:circle.yml
test:
  override:
    - docker run -v `pwd`/ansible:/ansible centos_ansible /bin/sh -c 'ansible-playbook /ansible/ci_site.yml -i /ansible/ci_hosts -c local && cd /ansible/spec && /home/develop/.rbenv/bin/rbenv exec bundle install && /home/develop/.rbenv/bin/rbenv exec bundle exec rake spec'
```

