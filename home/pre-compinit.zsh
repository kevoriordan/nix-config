function iterm2_print_user_vars() {
  iterm2_set_user_var kubecontext $(kubectl config current-context 2> /dev/null || echo "None")
  iterm2_set_user_var AWS_PROFILE $(echo $AWS_PROFILE)
  iterm2_set_user_var AWS_CLUSTER_NAME $(echo $AWS_CLUSTER_NAME)
}

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

