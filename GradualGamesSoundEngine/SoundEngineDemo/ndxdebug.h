.ifndef NDXDEBUG_H
NDXDEBUG_H = 1

.enum __NDXDebugType
    STRING
    BREAK
    START_PROFILING
    STOP_PROFILING
    LUA_EXEC_STR
    LUA_EXEC_FILE
.endenum

.macro __startNDXDebugInfo dbgtype
    .scope
    .scope __NDXDebug
        type = dbgtype
        PC = *
        .pushseg
        .segment "NDXDEBUG"
.endmacro

.macro __endNDXDebugInfo output_nop
        .popseg
    .endscope
    .endscope
    .ifnblank output_nop
        .if output_nop
            nop
        .endif
    .endif
.endmacro

; Output a string to the Debug Information window.
.macro ndxDebugOut str, output_nop
    .ifndef DEBUG
        .exitmac
    .endif
    
    __startNDXDebugInfo __NDXDebugType::STRING
        string_start:
        .byte str
        string_len = * - string_start
    __endNDXDebugInfo output_nop
.endmacro

; Macros for formatting the ndxDebugOut output.
.define ndxHex8( addr ) 1, 0, <(addr), >(addr)
.define ndxDec8( addr ) 1, 1, <(addr), >(addr)
.define ndxHex16( addr ) 1, 2, <(addr), >(addr)
.define ndxDec16( addr ) 1, 3, <(addr), >(addr)

; Execute a string as Lua code.
.macro ndxLuaExecStr str, output_nop
    __startNDXDebugInfo __NDXDebugType::LUA_EXEC_STR
        string_start:
        .byte str
        string_len = * - string_start
    __endNDXDebugInfo output_nop
.endmacro

; Execute a string as Lua code (only in DEBUG mode).
.macro ndxLuaExecStrDebug str, output_nop
    .ifndef DEBUG
        .exitmac
    .endif
    
    ndxLuaExecStr str, output_nop
.endmacro

; Execute a file as Lua code.
.macro ndxLuaExecFile str, output_nop
    __startNDXDebugInfo __NDXDebugType::LUA_EXEC_FILE
        string_start:
        .byte str
        string_len = * - string_start
    __endNDXDebugInfo output_nop
.endmacro

; Execute a file as Lua code (only in DEBUG mode).
.macro ndxLuaExecFileDebug str, output_nop
    .ifndef DEBUG
        .exitmac
    .endif
    
    ndxLuaExecFile str, output_nop
.endmacro

; Stop the emulator.
.macro ndxDebugBreak output_nop
    .ifndef DEBUG
        .exitmac
    .endif

    __startNDXDebugInfo __NDXDebugType::BREAK
    __endNDXDebugInfo output_nop
.endmacro

; Start code profiling.
.macro ndxStartProfiling output_nop
    .ifndef DEBUG
        .exitmac
    .endif

    __startNDXDebugInfo __NDXDebugType::START_PROFILING
    __endNDXDebugInfo output_nop
.endmacro

; Stop code profiling.
.macro ndxStopProfiling output_nop
    .ifndef DEBUG
        .exitmac
    .endif

    __startNDXDebugInfo __NDXDebugType::STOP_PROFILING
    __endNDXDebugInfo output_nop
.endmacro

.endif ; !NDXDEBUG_H
