
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name DigiLock -dir "X:/EC311/FinalProj/DigiLock/DigiLock-master/DigiLock/planAhead_run_1" -part xc6slx16csg324-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "X:/EC311/FinalProj/DigiLock/DigiLock-master/DigiLock/main.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {X:/EC311/FinalProj/DigiLock/DigiLock-master/DigiLock} }
set_property target_constrs_file "main.ucf" [current_fileset -constrset]
add_files [list {main.ucf}] -fileset [get_property constrset [current_run]]
link_design
