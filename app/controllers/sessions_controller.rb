class SessionsController < ApplicationController

  def create
    if params[:email].present? && params[:password].present?
    member_status = false
    # active_status = 0
    deactivate_message = false
    invalid_message = false
    errors = nil
    m_user = nil
    users = MUser.where(email: params[:email])
    users.each do |user|
      workspaces = MWorkspace.where(workspace_name: params[:workspace_name])
      workspaces.each do |workspace|
        tuserworkspace = TUserWorkspace.find_by(userid: user.id, workspaceid: workspace.id)
        if tuserworkspace.present?
          m_user = MUser.find_by(email: user.email, name: user.name)
        end
      end
    end
    # m_user.update(active_status: 1)
    m_workspace = MWorkspace.joins("INNER JOIN t_user_workspaces ON t_user_workspaces.workspaceid = m_workspaces.id
                                    INNER JOIN m_users ON m_users.id = t_user_workspaces.userid")
                            .where("m_workspaces.workspace_name = ? and m_users.email = ? ", params[:workspace_name],  params[:email]).take(1)
    if m_user && m_user.authenticate(params[:password]) && m_workspace.size > 0
      token_expired_at = 1.week.from_now
      token = encode(m_user.id, token_expired_at)
      t_user_workspace = TUserWorkspace.find_by(userid: m_user.id, workspaceid: m_workspace[0].id)
        if t_user_workspace
          if m_user.member_status == true
            member_status = true
          else
            deactivate_message = true
            errors = "アカウントを無効化します。管理者に連絡してください。"
          end
        else
          invalid_message = true
          errors = "名前とパスワードが間違っています"
        end
        render json: {  token:, errors:, user_workspace: t_user_workspace, member_status: , deactivate_message: , invalid_message: }, status: :ok
    else
      errors = "名前とパスワードが間違っています。"
      render json: { errors: }
      # render_unauthorized(CONSTANTS::ERR_LOGIN_FAILED)
    end
  else
    errors = "名前とパスワードが間違っています。"
    render json: { errors: }
  end
  end

  def destroy
    MUser.where(id: params[:user_id]).update_all(active_status: false)
    current_user = MUser.find_by(id: params[:user_id])
    render json: {status: 1}, status: :ok
  end

  def checkuser
    user = MUser.find_by(id: params[:user_id], member_status: true)
    render json: {user:}, status: :ok
  end

  def refresh
      unless params[:user_id].nil?
        @user = MUser.find_by(id: params[:user_id])
        MUser.where(id: params[:user_id]).update_all(active_status: true, updated_at: Time.new)
        render json: {successStatus: 1}, status: :ok 
      end        
  end

end
