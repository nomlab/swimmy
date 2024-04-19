require "json"
require "uri"
require 'open-uri'

module Swimmy
  module Service
    class RecipeInfomation

      class HttpException < StandardError; end

      def initialize(api_id)
        @api_id = api_id
      end

      def get_recipeinfo(food)
        begin
          category_id_hash = CookCategory.new(@api_id).get_category_id_hash
        rescue
          raise HttpException.new
        end

        begin
          recipe_ranking = get_reciperanking(food, category_id_hash)
          return nil if recipe_ranking.nil?
        rescue
          raise HttpException.new
        end

        top_ranking = recipe_ranking["result"][0]
        title = top_ranking["recipeTitle"]
        description = top_ranking["recipeDescription"]
        url = top_ranking["recipeUrl"]

        recipe_info = Resource::CookResource.new(title, description, url)

        return recipe_info
      end

      private
      def get_reciperanking(food, category_id_hash)
        recipe_candidates = category_id_hash.find_all{|key,value| key.include?(food)}
        return nil if recipe_candidates.empty?
        random_recipe_id = recipe_candidates.sample[1]
        # assigns the Id of a random category among the categories matching the argument

        begin 
          ranking_url = "https://app.rakuten.co.jp/services/api/Recipe/CategoryRanking/20170426?format=json&categoryId=#{random_recipe_id}&applicationId=" + @api_id
          # API仕様 : https://webservice.rakuten.co.jp/documentation/recipe-category-ranking
          recipe_ranking = JSON.parse(URI.open(ranking_url, &:read))
        rescue => e
          p e
          raise HttpException.new
        end

        return recipe_ranking
      end
    end

    class CookCategory
      def initialize(api_id)
        @api_id = api_id
      end

      def get_category_id_hash
        begin
          category_url = "https://app.rakuten.co.jp/services/api/Recipe/CategoryList/20170426?format=json&applicationId=" + @api_id
          # API仕様 : https://webservice.rakuten.co.jp/documentation/recipe-category-list
          result = JSON.parse(URI.open(category_url, &:read))
        rescue => e
          p e
          raise HttpException.new
        end

        category_id_hash = {}
        parent_id_hash = {}

        result["result"]["large"].each do |list|
          category_id_hash[list["categoryName"]] = list["categoryId"].to_s
        end
        result["result"]["medium"].each do |list|
          category_id_hash[list["categoryName"]] = list["parentCategoryId"].to_s + "-" +  list["categoryId"].to_s
          parent_id_hash[list["categoryId"]] = list["parentCategoryId"]
        end
        result["result"]["small"].each do |list|
          parent_id = parent_id_hash[list["parentCategoryId"].to_i]
          category_id_hash[list["categoryName"]] = parent_id + "-" + list["parentCategoryId"].to_s + "-" + list["categoryId"].to_s
        end
        # make a hash of category names and category Id

        return category_id_hash
      end
    end
  end
end
