module Api
  module V1
    class StatisticsController < ApplicationController
      def index
        @statistics = Statistic.last(10)
        render json: @statistics.as_json(only: %i[handler_type collection_size duration])
      end
    end
  end
end
