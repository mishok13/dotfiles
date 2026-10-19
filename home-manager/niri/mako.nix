{ ... }:

{
  xdg.configFile."mako/config".text = ''
    font=Hack Nerd Font 11
    width=360
    height=120
    margin=10
    padding=12
    border-size=2
    border-radius=8
    default-timeout=5000
    max-visible=5
    anchor=top-right

    background-color=#1e1e2e
    text-color=#cdd6f4
    border-color=#89b4fa
    progress-color=over #313244

    [urgency=low]
    border-color=#a6adc8

    [urgency=critical]
    border-color=#f38ba8
    default-timeout=0
  '';
}
