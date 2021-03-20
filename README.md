# loyola_crawler

## 環境構築
### selenium周りのライブラリのinstall

`$ bundle install --path vendor/bundle`

`$ brew install selenium-server-standalone`

`$ brew insltall selenium-webdriver`

### 環境変数の設定

`$ cp .env.sample .env`

`$ vim .env`

```.env
  LOYOLA_LOGIN_ID="ここを自身のLOYOLAのログインIDに変える"
  LOYOLA_LOGIN_PASSWORD="ここを自身のLOYOLAのログインパスワードに変える"
  
  export LOYOLA_LOGIN_ID LOYOLA_LOGIN_PASSWORD
```

## 使い方
`$ ruby script.rb`
