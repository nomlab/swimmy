module Swimmy
  module Command
    class Cook < Swimmy::Command::Base
    
      command "cook" do|client, data, match|
        food = match[:expression] || "" 

        client.say(channel: data.channel, text: "レシピ情報を取得しています……")
                
        begin
          rakuten_app_id = ENV['RAKUTEN_COOK_ID']
          recipe_info = Service::RecipeInfomation.new(rakuten_app_id).get_recipeinfo(food)

          message = if recipe_info then recipe_info.make_message else "レシピが見つかりませんでした．別のキーワードで再検索してください．" end

        rescue Service::RecipeInfomation::HttpException
          message = "通信に失敗しました．"
        end

        client.say(channel: data.channel, text: message)
      end

      help do
        title "cook"
        desc "指定した食べ物に対応したレシピを表示します．"
        long_desc   "cook \n" +
          "ランダムで選択したカテゴリのランキング1位のレシピを表示します． \n" +
          "cook <食べ物名>\n" +
          "指定した食べ物のランキング1位のレシピを表示します．"
      end
    end
  end
end
