# 
# Synthesis run script generated by Vivado
# 

set_param xicom.use_bs_reader 1
create_project -in_memory -part xc7a100tcsg324-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir C:/Users/ryan/Documents/415/Verilog-Platforming-Game/Deushane_415_game/Deushane_415_game.cache/wt [current_project]
set_property parent.project_path C:/Users/ryan/Documents/415/Verilog-Platforming-Game/Deushane_415_game/Deushane_415_game.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo c:/Users/ryan/Documents/415/Verilog-Platforming-Game/Deushane_415_game/Deushane_415_game.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_verilog -library xil_defaultlib {
  C:/Users/ryan/Documents/415/Verilog-Platforming-Game/Deushane_415_game/Deushane_415_game.srcs/sources_1/imports/sources_1/imports/imports/new/clk_50m_generator.v
  C:/Users/ryan/Documents/415/Verilog-Platforming-Game/Deushane_415_game/Deushane_415_game.srcs/sources_1/imports/sources_1/new/counter.v
  C:/Users/ryan/Documents/415/Verilog-Platforming-Game/Deushane_415_game/Deushane_415_game.srcs/sources_1/imports/sources_1/new/font_rom.v
  C:/Users/ryan/Documents/415/Verilog-Platforming-Game/Deushane_415_game/Deushane_415_game.srcs/sources_1/imports/sources_1/imports/imports/ch13/list_ch13_01_vga_sync.v
  {C:/Users/ryan/Documents/415/Verilog-Platforming-Game/Deushane_415_game/Deushane_415_game.srcs/sources_1/imports/sources_1/imports/ch13/list_ch13_05_ pong_graph_animate.v}
  C:/Users/ryan/Documents/415/Verilog-Platforming-Game/Deushane_415_game/Deushane_415_game.srcs/sources_1/imports/sources_1/new/pong_text.v
  C:/Users/ryan/Documents/415/Verilog-Platforming-Game/Deushane_415_game/Deushane_415_game.srcs/sources_1/imports/new/ps2RX.v
  C:/Users/ryan/Documents/415/Verilog-Platforming-Game/Deushane_415_game/Deushane_415_game.srcs/sources_1/imports/sources_1/imports/imports/ch13/list_ch13_04_pong_top_st.v
}
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc C:/Users/ryan/Documents/415/Verilog-Platforming-Game/Deushane_415_game/Deushane_415_game.srcs/constrs_1/imports/415/Nexys4DDR_Master.xdc
set_property used_in_implementation false [get_files C:/Users/ryan/Documents/415/Verilog-Platforming-Game/Deushane_415_game/Deushane_415_game.srcs/constrs_1/imports/415/Nexys4DDR_Master.xdc]


synth_design -top pong_top_st -part xc7a100tcsg324-1


write_checkpoint -force -noxdef pong_top_st.dcp

catch { report_utilization -file pong_top_st_utilization_synth.rpt -pb pong_top_st_utilization_synth.pb }
