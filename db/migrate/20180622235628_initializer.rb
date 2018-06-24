class Initializer < ActiveRecord::Migration[5.0]
  def change
  	# ユーザー
  	create_table :users do |t|
  		t.string :nick_name, comment: "ニックネーム"
  		t.text :description, comment: "説明"
  		t.string :web_site, comment: "ウェブサイト"
  		t.string :instagram, comment: " インスタグラム"
  		t.string :twitter, comment: "Twitter"
  		t.string :facebook, comment: "Facebook"
  		t.string :cavar_image, comment: "背景画像"
  		t.string :image, comment: "画像"
  		t.string :email, comment: "メールアドレス"
  		t.string :hashed_password, comment: "パスワード"
      t.string :salt, comment: "パスワードハッシュ化"
  		t.integer :deleted, default: 0, null: false, comment: "削除"
  		t.timestamps
  	end

  	# コメントのいいね
  	create_table :comment_likes do |t|
  		t.integer :user_id, comment: "ユーザーID"
  		t.integer :comment_id, comment: "コメントID"
  		t.integer :deleted, default: 0, null: false, comment: "削除"
  		t.timestamps
  	end

  	# 記事のいいね
  	create_table :article_likes do |t|
  		t.integer :user_id, comment: "ユーザーID"
  		t.integer :article_id, comment: "記事ID"
  		t.integer :deleted, default: 0, null: false, comment: "削除"
  		t.timestamps
  	end

  	# 記事
  	create_table :articles do |t|
  		t.integer :category_id, comment: "カテゴリID"
  		t.string :title, comment: "記事タイトル"
  		t.text :description, comment: "記事内容"
  		t.datetime :post_date, comment: "記事作成日"
  		t.datetime :expire_date, comment: "記事更新日"
  		t.integer :view_count, comment: "閲覧数"
  		t.string :image, comment: "画像"
  		t.integer :deleted, default: 0, null: false, comment: "削除"
  		t.integer :available,default: 0, null: false, comment: "表示"
  		t.timestamps
  	end

  	# 記事コメント
  	create_table :comments do |t|
  		t.integer :user_id, comment: "ユーザーID"
  		t.integer :article_id, comment: "記事ID"
  		t.text :description, comment: "内容"
  		t.integer :deleted, default: 0, null: false, comment: "削除"
  		t.timestamps
  	end

  	# ランキング
  	create_table :runkings do |t|
  		t.integer :article_id, comment: "記事ID"
  		t.integer :sort_seq, comment: "並び順"
  		t.integer :deleted, default: 0, null: false, comment: "削除"
  		t.timestamps
  	end

  	# カテゴリランキング
  	create_table :category_runkings do |t|
  		t.integer :category_id, comment: "カテゴリID"
  		t.integer :article_id, comment: "記事ID"
  		t.integer :sort_seq, comment: "並び順"
  		t.integer :deleted, default: 0, null: false, comment: "削除"
  		t.timestamps
  	end

  	# 記事カテゴリ
  	create_table :categories do |t|
  		t.string :title, comment: "コメント"
  		t.string :code, comment: "コード"
  		t.text :description, comment: "内容"
  		t.string :image, comment: "画像"
  		t.integer :sort_seq, comment: "並び順"
  		t.integer :deleted, default: 0, null: false, comment: "削除"
  		t.integer :available,default: 0, null: false, comment: "表示"
  		t.timestamps
  	end

  	# 記事タグ
  	create_table :tags do |t|
  		t.string :title, comment: "タイトル"
  		t.integer :category_id, comment: "カテゴリID"
  		t.integer :article_id, comment: "記事ID"
  		t.integer :sort_seq, comment: "並び順"
  		t.integer :deleted, default: 0, null: false, comment: "削除"
  		t.integer :available,default: 0, null: false, comment: "表示"
  		t.timestamps
  	end

  	# 中間テーブル(タグ)
  	create_table :article_tags do |t|
  		t.integer :article_id, comment: "記事ID"
  		t.integer :tag_id, comment: "タグID"
  		t.timestamps
  	end

  	# 記事コンテンツ
  	create_table :contents do |t|
  		t.integer :article_id, comment: "記事ID"
  		t.integer :type, comment: "コンテンツタイプ"
  		t.string :title, comment: "タイトル"
  		t.text :description, comment: "内容"
  		t.string :link_text, comment: "リンク名"
  		t.string :link_url, comment: "リンクURL"
  		t.string :movie_text, comment: "動画名"
  		t.string :movie_url, comment: "動画URL"
  		t.string :twitter_url, comment: "Twitter_URL"
  		t.string :facebook_url, comment: "facebook_URL"
  		t.string :instagram_url, comment: " Instagram_URL"
  		t.integer :deleted, default: 0, null: false, comment: "削除"
  		t.integer :available,default: 0, null: false, comment: "表示"
  		t.timestamps
  	end

    # 記事画像
  	create_table :content_images do |t|
  		t.integer :content_id, comment: "コンテンツID"
  		t.string :image, comment: "画像"
  		t.string :image_text, comment: "画像テキスト"
  		t.integer :deleted, default: 0, null: false, comment: "削除"
  		t.integer :available, default: 0, null: false, comment: "表示"
  		t.timestamps
  	end

    # 管理者
    create_table :admin_users do |t|
      t.string :name, comment: "名前"
      t.string :email, comment: "メールアドレス"
      t.string :hashed_password, comment: "パスワード"
      t.string :salt, comment: "パスワードハッシュ化"
      t.integer :deleted, default: 0, null: false, comment: "削除"
      t.timestamps
    end

    # 検索条件保存
    create_table :sql_conditions do |t|
      t.string :code
      t.integer :admin_user_id
      t.text :condition, default: "", null: false
      t.timestamps
    end
  end
end
