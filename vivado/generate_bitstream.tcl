# Only tested on Vivado 2020.1 on Windows 10

# set variables
set project_dir riscv-basys3
set project_name riscv-basys3
set part xc7a35tcpg236-1
set sources {../verilog/BCD2Segments.v ../verilog/OnboardDigitDisplay.v ../verilog/Top.v ../verilog/SegmentMux.v}

# open the project. will create one if it doesn't exist 
if {[file exist $project_dir]} {
    # check that it's a directory
    if {! [file isdirectory $project_dir]} {
        puts "$project_dir exists, but it's a file"
    }
    open_project $project_dir/$project_name.xpr -part $part 
} else {
    create_project riscv-basys3 riscv-basys3 -part $part
}

add_files -norecurse $sources
update_compile_order -fileset sources_1
add_files -fileset constrs_1 -norecurse ./basys3.xdc
while 1 {
    if { [catch {launch_runs impl_1 -to_step write_bitstream -jobs 4} ] } {
        regexp {ERROR: \[Vivado (\d+-\d+)]} $errorInfo -> code
        if { [string equal $code "12-978"] } {
            puts "Already generated and up-to-date"
            break
        } elseif { [string equal $code "12-1088"] } {
            puts "Out of date, reset runs"
            reset_runs impl_1
            continue
        } else {
            puts "UNKNOWN ERROR!!! $errorInfo"
            exit
        }
    }
    break
}

wait_on_run [current_run]
