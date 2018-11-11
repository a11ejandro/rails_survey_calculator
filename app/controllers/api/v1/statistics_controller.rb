module Api
  module V1
    class StatisticsController < ApplicationController
      def index
        @task = Task.last
        render json: @task.statistics.as_json(only: %i[handler_type collection_size duration])
      end
    end
  end
end
