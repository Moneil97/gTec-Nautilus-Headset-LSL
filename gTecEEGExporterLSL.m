classdef gTecEEGExporterLSL < matlab.System
    % Gets 18 EEG Channels from Lab Streaming Layer
    
    methods(Access = protected)
        function setupImpl(~)
            coder.extrinsic('evalin')
            coder.extrinsic('assignin');
            
            evalin('base', "addpath(genpath(pwd))") %Recursively add current dir to path
            
            %lib = lsl_loadlib();
            assignin('base', 'lib', evalin('base', 'lsl_loadlib()')); %load lsl
            
            %info = lsl_streaminfo(lib,'gTec','EEG',32,500,'cf_float32','gTecHeadset1');
            assignin('base', 'info', evalin('base', "lsl_streaminfo(lib,'gTec','EEG',32,500,'cf_double64','gTecHeadset1')"))
            
            %outlet = lsl_outlet(info);
            assignin('base', 'outlet', evalin('base', 'lsl_outlet(info)'));
        end
        
        function stepImpl(~, chunk)
            coder.extrinsic('evalin');
            coder.extrinsic('assignin');
            
            %push chunk to LSL output stream
            %assignin('base', 'chunk', transpose(chunk));
            %evalin('base', 'outlet.push_chunk(double(chunk))');
            
            %break up chunk into 8 samples and push each seperately
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