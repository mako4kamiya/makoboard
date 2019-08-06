###
#ライブラリの読み込み
##
require 'sinatra'
require 'sinatra/reloader'
require 'fileutils' #画像フォルダを扱います。
require 'sinatra/cookies' #クッキーを使います。
require 'pg' #PostgeSQLを使えるようにする。

###
#sinatraの設定
##
set :public_folder, 'public'
enable :sessions #セッションを使います

###
#DBの設定？
##
def db
    host = 'localhost'
    user = 'kamiyamasako' #自分のユーザー名を入れる
    password = ''
    dbname = 'makoboard'
    
    # PostgreSQL クライアントのインスタンスを生成
    PG::connect(
    :host => host,
    :user => user,
    :password => password,
    :dbname => dbname)
end
###
#ルーティン
##

#セッションがあるかどうかの確認
get '/' do
    if session[:user_id].nil? == true #セッションが空ならsigninを読み込む
        erb :home
    else #空じゃなかったらindexを読み込む
        redirect 'index'
    end
end

#/signupにアクセスすると、サインアップ（新規登録）画面が表示される。
get '/signup' do
    erb :signup
end

#signupで記入した内容がusersテーブルに保存される。
post '/signup' do
    name = params[:name]
    email = params[:email]
    password = params[:password]
    db.exec("INSERT INTO users(name, email, password) VALUES($1,$2,$3)",[name,email,password])
    redirect '/signin'
end

#/signinにアクセスすると、サインイン画面が表示される。
get '/signin' do
    erb :signin
end

#サインアップ（登録）されてるかの確認
post '/signin' do
    name = params[:name]
    password = params[:password]
    puts "hello"
    users_id = db.exec("SELECT id FROM users WHERE name = $1 AND password = $2",[name,password]).first
    if users_id.nil? == true #signinで入力したnameとpasswordがusersテーブルに無ければ、signupを読み込む
        redirect 'signup'
    else #signinで入力したnameとpasswordがusersテーブルにあれば、その列のidをsessionに入れて、indexを読み込む。
        session[:user_id] = users_id['id'] #ハッシュ（id）を指定して、値(1とか)を持ってきてる。
        redirect 'index'
    end
end

#/index にアクセスすると、掲示板の内容一覧と投稿画面が表示される
get '/index' do
    if session[:user_id].nil? == true #セッションが空ならsigninを読み込む
        redirect 'signin'
    else #空じゃなかったらindexを読み込む
        active_user = session[:user_id]
        @posts = db.exec_params("SELECT * FROM posts")
        @active_user = db.exec("SELECT name FROM users WHERE id = $1",[active_user]).first
        erb :index
    end
end

get '/post' do
    erb :post
end

#/post にアクセスすると、投稿された内容がデータベースに保存される
post '/post' do
    active_user = session[:user_id]
    content = params[:content]
    users_name = db.exec("SELECT name FROM users WHERE id = $1",[active_user]).first
    user_name = users_name['name']
    puts "hello"
    p user_name
    db.exec("INSERT INTO posts(user_id,content,user_name) VALUES($1,$2,$3)",[active_user,content,user_name])
    redirect '/index'
end