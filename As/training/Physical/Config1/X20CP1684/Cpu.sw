<?xml version="1.0" encoding="utf-8"?>
<?AutomationStudio FileVersion="4.9"?>
<SwConfiguration CpuAddress="" xmlns="http://br-automation.co.at/AS/SwConfiguration">
  <TaskClass Name="Cyclic#1">
    <Task Name="muj1" Source="muj1.prg" Memory="UserROM" Language="ANSIC" Debugging="true" />
  </TaskClass>
  <TaskClass Name="Cyclic#2" />
  <TaskClass Name="Cyclic#3" />
  <TaskClass Name="Cyclic#4">
    <Task Name="CfgStorage" Source="cfgHandler.CfgStorageOld.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="CfgStorag1" Source="cfgHandler.CfgStorage.prg" Memory="UserROM" Language="ANSIC" Debugging="true" />
  </TaskClass>
  <TaskClass Name="Cyclic#5" />
  <TaskClass Name="Cyclic#6" />
  <TaskClass Name="Cyclic#7" />
  <TaskClass Name="Cyclic#8" />
  <Binaries>
    <BinaryObject Name="udbdef" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="TCData" Source="" Memory="SystemROM" Language="Binary" />
    <BinaryObject Name="FWRules" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="iomap" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="ashwac" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="sysconf" Source="" Memory="SystemROM" Language="Binary" />
    <BinaryObject Name="arconfig" Source="" Memory="SystemROM" Language="Binary" />
    <BinaryObject Name="asfw" Source="" Memory="SystemROM" Language="Binary" />
    <BinaryObject Name="BRRole" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="ashwd" Source="" Memory="SystemROM" Language="Binary" />
    <BinaryObject Name="UaCsConfig" Source="" Memory="UserROM" Language="Binary" />
  </Binaries>
  <Libraries>
    <LibraryObject Name="UaCore" Source="" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="standard" Source="Libraries.standard.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="HzLogger" Source="cfgHandler.HzLogger.lby" Memory="UserROM" Language="ANSIC" Debugging="true" />
    <LibraryObject Name="runtime" Source="Libraries.runtime.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsBrStr" Source="cfgHandler.AsBrStr.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="ArEventLog" Source="cfgHandler.ArEventLog.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="MpRecipe" Source="Libraries.MpRecipe.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="MpBase" Source="Libraries.MpBase.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="sys_lib" Source="Libraries.sys_lib.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="astime" Source="Libraries.astime.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="HeinzAux" Source="cfgHandler.HeinzAux.lby" Memory="UserROM" Language="ANSIC" Debugging="true" />
    <LibraryObject Name="CheckLib" Source="cfgHandler.CheckLib.lby" Memory="UserROM" Language="ANSIC" Debugging="true" />
    <LibraryObject Name="AsOpcUac" Source="Libraries.AsOpcUac.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="OpcSimple" Source="Libraries.OpcSimple.lby" Memory="UserROM" Language="ANSIC" Debugging="true" />
  </Libraries>
</SwConfiguration>