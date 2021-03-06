module Api::V1
class ChallengesController < ApplicationController
  before_filter :set_leaderboard

  # POST to /leaderboards/:leaderboard_id/challenges with params:
  # {
  #   sender_id:
  #   receiver_ids: [x, y, z]
  # }
  #
  # This method stuffs the sender_id, receiver_id, and leaderboard_id into push
  # queue to be handled later.  Push queues are keyed by developer_id:push_queue.
  def create
    sender_id      = params[:sender_id] && params[:sender_id].to_i
    receiver_ids   = params[:receiver_ids] && params[:receiver_ids].is_a?(Array) && params[:receiver_ids].map(&:to_i)

    challenge = Challenge.new(
        sender_id: sender_id,
        receiver_ids: receiver_ids,
        leaderboard: @leaderboard,
        app: authorized_app,
        sandbox: in_sandbox?
    )

    if challenge.save
      head :ok
    else
      render status: :bad_request, json: {message: challenge.errors.join(", ")}
    end
  end

  private
  def set_leaderboard
    @leaderboard = authorized_app && authorized_app.leaderboards.find_by_id(params[:leaderboard_id].to_i)
    unless @leaderboard
        render :status => :forbidden, :json => { message: "You do not have access to this leaderboard." }
    end
  end
end
end
