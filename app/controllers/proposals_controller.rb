class ProposalsController < ApplicationController
  before_action :admin_or_author_user,  only: [:edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :vote_for, :vote_against]

  impressionist :unique => [:session_hash], :actions => [:show]

  def index
    if params[:order]
      @proposals = change_order(params[:order]).paginate(page: params[:page])
    else
      @proposals = Proposal.paginate(page: params[:page])
    end
  end

  def new
    @proposal = Proposal.new
  end

  def create
    @proposal = current_user.proposals.build(proposal_params)
    if @proposal.save
      flash[:success] = "Proposta submetida."
      redirect_to @proposal
    else
      render 'new'
    end
  end

  def edit
    @proposal = Proposal.find(params[:id])
  end

  def show
    @proposal = Proposal.find(params[:id])
  end

  def update
    @proposal = Proposal.find(params[:id])  # TODO FIXME this shouldn't be needed
    if @proposal.update_attributes(proposal_params)
      flash[:success] = "Proposta alterada."
      redirect_to @proposal
    else
      render 'edit'
    end
  end

  def destroy
    @proposal = Proposal.find(params[:id])  # TODO FIXME this shouldn't be needed
    @proposal.destroy
    flash[:success] = "Proposta apagada."
    redirect_to user_path(current_user)
  end

  def vote_for
    # TODO show updated number to user AJAX: http://goo.gl/byMMZ2
    begin
      current_user.vote_for(@proposal = Proposal.find(params[:id]))
      flash[:success] = "Voto efectuado."
    rescue ActiveRecord::RecordInvalid
      flash[:error] = "Voto não efectuado: só pode votar uma vez e não pode alterá-lo."
    end
    respond_to do |format|
      format.js
      format.html {redirect_to :back}
    end
  end

  def vote_against
    # TODO show updated number to user AJAX: http://goo.gl/byMMZ2
    begin
      current_user.vote_against(@proposal = Proposal.find(params[:id]))
      flash[:success] = "Voto efectuado."
    rescue ActiveRecord::RecordInvalid
      flash[:error] = "Voto não efectuado: só pode votar uma vez e não pode alterá-lo."
    end
    respond_to do |format|
      format.js
      format.html {redirect_to :back}
    end
  end

  def change_order(new_order)
    case new_order
      when 'recent'
        Proposal.order('created_at DESC')
      when 'voted'
        Proposal.all.sort { |p1, p2| p2.total_votes <=> p1.total_votes }
      when 'popular'
        Proposal.all.sort { |p1, p2| p2.impressionist_count(start_date: Date.today, end_date: Date.today.prev_month) <=>
          p1.impressionist_count(start_date: Date.today, end_date: Date.today.prev_month) }
      when 'polemic'
        Proposal.all
          .select { |proposal|
            proposal.total_votes > CONTROVERSIAL_THRESHOLD &&
            proposal.score <= 0.1*CONTROVERSIAL_THRESHOLD &&
            proposal.score > -0.1*CONTROVERSIAL_THRESHOLD }
          .sort{ |p1, p2| p2.total_votes <=> p1.total_votes }
      else
        Proposal.order('created_at DESC')
    end
  end


  # ==== Begin of tag-related views
  def tagged
    if params[:tag].present?
      @proposals = Proposal.tagged_with(params[:tag])
    else
      @proposals = []
    end
  end
  # ==== End of tag-related views

  private

    def proposal_params
      params.require(:proposal).permit(:title, :problem, :solution, :tag_list)
    end

    # Before filters

    def admin_or_author_user
      allowed = current_user.admin?
      if !allowed
        @proposal = current_user.proposals.find_by(id: params[:id])
        redirect_to(root_url) if @proposal.nil?
      end
    end

end
