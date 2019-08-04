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

# get '/index' do
#     @posts = db.exec_params("SELECT * FROM posts")
#     erb :index
# end

#/registerにアクセスすると、登録画面が表示される。
get '/signup' do
    erb :signup
end

#/registerにアクセスすると、記入した内容がデータベースに保存される。
post '/signup' do
    name = params[:name]
    email = params[:email]
    password = params[:password]
    db.exec("INSERT INTO users(name, email, password) VALUES($1,$2,$3)",[name,email,password])
    redirect '/signin'
end

get '/signin' do
    erb :signin
end

post '/signin' do
    name = params[:name]
    password = params[:password]
    puts "hello"
    user_id = db.exec("SELECT id FROM users WHERE name = $1 AND password = $2",[name,password]).first
    session[:user_id] = user_id['id'] #ハッシュ（id）を指定して、値(1とか)を持ってきてる。
    redirect '/index'
end

#/index にアクセスすると、掲示板の内容一覧と投稿画面が表示される
get '/index' do
    @posts = db.exec_params("SELECT * FROM posts")
    erb :index
end

get '/post' do
    erb :post
end

#/post にアクセスすると、投稿された内容がデータベースに保存される
post '/post' do
    name = params[:name]
    email = params[:email]
    content = params[:content]
    db.exec("INSERT INTO posts(name, email, content) VALUES($1,$2,$3)",[name,email,content])
    redirect '/'
end


