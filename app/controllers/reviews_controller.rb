class ReviewsController < ApplicationController
  require 'nokogiri'
  require 'open-uri'
  require 'rubyXL'
  def top
  end

  def scrape
    #カウンターの追加
    count = 0

    #商品名を変数paramsで受け取る
    input_name = params[:name]

    #入力フォームの値を変数paramsで受け取る
    input_url = params[:page_url]
    unless input_url[/https:\/\/www.cosme.net\/product\/product_id\/\d{8}\/top/]
      flash[:alert] = "URLの形式は、https:/www.cosme.net/product/product_id/数字6or8桁/top　です"
      redirect_to("/") and return
    end

    #取得レビュー数を変数paramsで受け取る
    limit = params[:rev_count]
    unless limit[/[+-]?\d+/]
      flash[:alert] = "整数値を入力してください"
      redirect_to("/") and return
    end

    #変数tableの空配列を作成し、date_setを配列要素として格納する
    table = []

    doc = Nokogiri::HTML.parse(open(input_url, "r:Shift_JIS:UTF-8").read)
    url_lists = doc.css("div.product-inst-review").to_s
    review_url = url_lists[/https:\/\/www.cosme.net\/product\/product_id\/\d{8}\/review\/\d{9}/]
    
    #取得レビュー数回スクレイピングする
    while count <= limit.to_i
      
      #文字コードをUTF-8に変換（@cosmeの文字コードはShift_JISなので）
      doc = Nokogiri::HTML.parse(open(review_url, "r:Shift_JIS:UTF-8").read)
      
      #配列data_setに代入する各データ（名前・年齢・肌質・星・ステータス１・ステータス２・日付・投稿本文）を抜き出す

      #ブランド名/商品名
      item_name = doc.css("h2.item-name").text

      #レビューの投稿内容
      rev_content = doc.css("p.read").text

      #レビュー投稿の日付
      date = doc.css("div.clearfix").text
      rev_date = date[/\d{4}+\/\d+\/\d+/]

      #レビューの評価星
      star = doc.css("p.reviewer-rating").text
      rev_stars = star[/\d/]

      #個人PF(名前・年齢・肌質)
      user_info = doc.css("div.reviewer-info").text
      user_name = user_info[/.*さん/]
      user_age = user_info[/\d{2}歳/]
      skin = /歳(.+)クチコミ/.match(user_info)
      user_skin = skin[1].to_s

      #ステータス１（購入品）
      if doc.css("span.buy")
        status_buy = doc.css("span.buy").text
      else
        status_buy = "N/A"
      end

      #ステータス２(リピート）
      if doc.css("span.repeat")
        status_rep = doc.css("span.repeat").text
      else
        status_rep = "N/A"
      end

      #空配列date_setに各要素を代入する
      date_set = []
      date_set[0] = user_name
      date_set[1] = user_age
      date_set[2] = user_skin
      date_set[3] = rev_stars
      date_set[4] = status_buy
      date_set[5] = status_rep
      date_set[6] = rev_date.to_s
      date_set[7] = rev_content
      date_set[8] = item_name

      #変数tableに配列要素として代入する　
      table << date_set

      next_urllist = doc.css("li.next").to_s
      next_url = next_urllist[/https:\/\/www.cosme.net\/product\/product_id\/\d{8}\/review\/\d{9}/]
      review_url = next_url.to_s

      #カウンターを追加
      count += 1
    end

    #フォーマットエクセルを選択
    workbook = RubyXL::Parser.parse("@cosme_format.xlsx")

    #1ページ目
    worksheet_0 = workbook[0]
    worksheet_0.sheet_name = "レビュー全文版"

    l = 1
    table.each do |record|
      worksheet_0.add_cell(l,0,"#{record[0]}")
      worksheet_0.add_cell(l,1,"#{record[1]}")
      worksheet_0.add_cell(l,2,"#{record[2]}")
      worksheet_0.add_cell(l,3,"#{record[3]}")
      worksheet_0.add_cell(l,4,"#{record[4]}")
      worksheet_0.add_cell(l,5,"#{record[5]}")
      worksheet_0.add_cell(l,6,"#{record[6]}")
      worksheet_0.add_cell(l,7,"#{record[7]}")
      l+=1
    end

    #2ページ目
    worksheet_1 = workbook[1]
    worksheet_1.sheet_name = "レビュー文単位版"

    l = 1
    table.each do |record|
      worksheet_1.add_cell(l,0,"#{record[0]}")
      worksheet_1.add_cell(l,1,"#{record[1]}")
      worksheet_1.add_cell(l,2,"#{record[2]}")
      worksheet_1.add_cell(l,3,"#{record[3]}")
      worksheet_1.add_cell(l,4,"#{record[4]}")
      worksheet_1.add_cell(l,5,"#{record[5]}")
      worksheet_1.add_cell(l,6,"#{record[6]}")
      record[7].split(/[。！？]/).each do |sente|
        worksheet_1.add_cell(l,7,"#{sente}")
        l+=1
      end
    end

    #保存
    file_name = "@cosmeレビュー収集結果＿#{input_name}.xlsx"
    workbook.write(file_name)
    send_file Rails.root.join("@cosme_format.xlsx")
    flash[:success]="レビュー収集が完了しました。"
    redirect_to("/")
  end

  def download
    filepath = Rails.root.join("@cosme_format.xlsx")
    stat = File::stat(filepath)
    send_file(filepath, :filename => 'test.xlsx', :length => stat.size)
  end
end