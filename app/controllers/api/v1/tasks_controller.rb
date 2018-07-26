module Api
  module V1
    class TasksController < ApplicationController
      def create
        @task = Task.create(task_params)
        render json: {
          message: "Task ##{@task.id} successfully created."
        }
      end

      private

      def task_params
        params[:task].permit(:page, :per_page)
      end
    end
  end
end
