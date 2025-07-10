# スクレイピング対象のwebサイトは例えば以下のようになっている

# <div id="daily-ranking">
#     <ul class="p-song-list p-ranking-list" data-defoult="10">

# <li class="p-song-list__item p-ranking-list__item">
#                 <div class="p-song-unit p-song-unit--ellipsis">
# <a class="p-song-unit__sp-link" href="/karaokesearch/songleaf.html?requestNo=1447-11"></a><a class="p-song p-song--song p-ranking" href="/karaokesearch/songleaf.html?requestNo=1447-11">

#                     <div class="p-ranking__num p-ranking__num--first">1</div>
	
#                     <div class="p-song__inner">
# 	            	<div class="p-song__tieup">『忘却バッテリー』</div>
#                       <h4 class="p-song__title">ライラック</h4>
#                       <div class="p-song__artist">Mrs. GREEN APPLE</div>
#                     </div>
#                   </a><a class="p-song p-song--artist" href="/karaokesearch/artistleaf.html?artistCode=108199">
#                     <div class="p-song__inner">
#                       <div class="p-song__artist">Mrs. GREEN APPLE</div>
#                     </div>
#                   </a>
# </div>
#               </li>

# 今回実装した手法では，ランキングの曲のみを取得する. 例えばデイリーランキングを取得するときは，
# "daily-ranking"の中の"p-song-list__item p-ranking-list__item"というクラスを探索し，
# 順位やタイトルが含まれているhtmlを取得する．次に，取得したhtmlから"p-ranking__num"，"p-song__title"
# をというクラスをそれぞれ探索し，順位と曲のタイトルをそれぞれ取得する．

require 'open-uri'
require 'nokogiri'

module Swimmy
  module Service
    class Karaoke
      def initialize(url)
        @url = url
      end
       
      def get_karaoke_info(ranking_span, max_ranking=10)

        song_ranking = {}                 
        html = URI.open(@url).read
        doc = Nokogiri::HTML.parse(html)

        #"{ranking_span}-ranking"の中の"p-song-list__item p-ranking-list__item"というクラスを探索
        #{ranking_span}にはdaily, weekly, monthlyのいずれかが入力される
        # 例えばデイリーランキングを取得するときは，"daily-ranking"の中の"p-song-list__item p-ranking-list__item"
        # というクラスを探索し，順位やタイトルが含まれているhtmlを取得する．
        doc.xpath(%Q{//div[@id="#{ranking_span}-ranking"]//li[@class="p-song-list__item p-ranking-list__item"]}).each do |str|
          # "p-ranking__num"，"p-song__title"をそれぞれ取得し，ranking_list,song_listに格納する．
          ranking = str.xpath('.//div[contains(@class, "p-ranking__num")]').text.strip
          song = str.xpath('.//h4[@class="p-song__title"]').text.strip
          song_ranking[ranking] = song
          if ranking.to_i == max_ranking
            break
          end
        end
        return song_ranking
      end # get_karaoke_info
    end # class Karaoke
  end # module service
end # module swimmy
