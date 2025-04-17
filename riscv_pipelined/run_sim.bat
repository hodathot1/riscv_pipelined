@echo off
setlocal enabledelayedexpansion

echo 1. Mô phỏng IF Stage
echo 2. Mô phỏng ID Stage
echo 3. Mô phỏng EX Stage
echo 4. Mô phỏng MEM Stage
echo 5. Mô phỏng WB Stage
echo 6. Mô phỏng Full Pipeline
echo.

set /p choice="chọn (1-6): "

if "%choice%"=="1" (
    echo Running IF Stage simulation...
    iverilog -o if_stage_sim testbench/if_stage_tb.v src/if_stage.v
    vvp if_stage_sim
    gtkwave dump.vcd
) else if "%choice%"=="2" (
    echo Running ID Stage simulation...
    iverilog -o id_stage_sim testbench/id_stage_tb.v src/id_stage.v
    vvp id_stage_sim
    gtkwave dump.vcd
) else if "%choice%"=="3" (
    echo Running EX Stage simulation...
    iverilog -o ex_stage_sim testbench/ex_stage_tb.v src/ex_stage.v
    vvp ex_stage_sim
    gtkwave dump.vcd
) else if "%choice%"=="4" (
    echo Running MEM Stage simulation...
    iverilog -o mem_stage_sim testbench/mem_stage_tb.v src/mem_stage.v
    vvp mem_stage_sim
    gtkwave dump.vcd
) else if "%choice%"=="5" (
    echo Running WB Stage simulation...
    iverilog -o wb_stage_sim testbench/wb_stage_tb.v src/wb_stage.v
    vvp wb_stage_sim
    gtkwave dump.vcd
) else if "%choice%"=="6" (
    echo Running Full Pipeline simulation...
    iverilog -o pipeline_sim testbench/riscv_pipelined_testbench.v src/riscv_pipelined_core.v src/if_stage.v src/id_stage.v src/ex_stage.v src/mem_stage.v src/wb_stage.v src/hazard_control.v
    vvp pipeline_sim
    gtkwave dump.vcd
) else (
    echo Invalid choice!
    exit /b 1
)

exit /b 0