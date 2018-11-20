classdef gTecEEGExporterLSL < matlab.System
    %Takes the EEG Data output of the g.Nautilus Block provided by gTec 
    %and outputs it to Lab Streaming Layer as 1x32 chunks
    %made for 32 channel headsets, but will likely work for 64 as well
    %with minor modifications
    
    methods(Access = protected)
        function setupImpl(~)
            coder.extrinsic('evalin')
            coder.extrinsic('assignin');
            
            evalin('base', "addpath(genpath(pwd))") %Recursively add current dir to path
            
            %lib = lsl_loadlib();
            assignin('base', 'lib', evalin('base', 'lsl_loadlib()')); %load lsl
            
            %info = lsl_streaminfo(lib,'gTec','EEG',32,500,'cf_double64','gTecHeadset1');
            assignin('base', 'info', evalin('base', "lsl_streaminfo(lib,'gTec','EEG',32,500,'cf_double64','gTecHeadset1')"))
            
            %outlet = lsl_outlet(info);
            assignin('base', 'outlet', evalin('base', 'lsl_outlet(info)'));
        end
        
        %chunk is [8x32] of EEG Data
        function stepImpl(~, chunk)
            coder.extrinsic('evalin');
            coder.extrinsic('assignin');
            
            %break up chunk into 8 samples and push each seperately
            %[8x32] -> 8 [1x32] samples
            for x = 1:8
                assignin('base', 'sample', chunk(x,:));
                evalin('base', 'outlet.push_sample(double(sample))');
            end
        end
        
        function releaseImpl(~)
            coder.extrinsic('evalin');
            evalin('base', 'outlet.delete()');
        end
    end
end