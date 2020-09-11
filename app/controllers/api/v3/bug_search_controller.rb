module Api
  module V3
    class BugSearchController < Api::V3::ApplicationController
      def index
        params[:q] ||= ""

        search_modules = [Topic]
        search_params = {
          query: {
            filtered: {
              query: {
                simple_query_string: {
                  query: params[:q],
                  default_operator: "AND",
                  minimum_should_match: "70%",
                  fields: %w(title body name login)
                }
              },
              filter: {
                bool: {
                  must_not: {
                    term: {
                      draft: true
                    }
                  },
                  must_not: {
                    term: {
                      private_org: true
                    }
                  }
                }
              }
            }
          },
          highlight: {
            pre_tags: ["[h]"],
            post_tags: ["[/h]"],
            fields: { title: {}, body: {}, name: {}, login: {} }
          }
        }
        @result = Elasticsearch::Model.search(search_params, search_modules).page(params[:page])
        @topics = @result.records.to_a

        if params[:source] == "huawei"
          @topics = @topics.reject { |t| t.node_id != Node.bugs_id }
          @topics = @topics.reject { |tt| !tt.title.index(/ios|iphone|mac/i).nil? }
        end
        render json: @topics
      end
    end
  end
end
