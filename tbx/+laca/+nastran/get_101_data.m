function [data,folder_name] = get_101_data(model,varargin)
    p = inputParser();
    p.addParameter('Silent',true);
    p.addParameter('bin_folder',[]);
    p.parse(varargin{:});
    
    folder_name = laca.nastran.create_tmp_bin(p.Results.bin_folder);
    % write the model 
    model.writeToFolder(fullfile(folder_name,'Source','Model'));
    
    % run NASTRAN
    current_folder = pwd;
    cd(fullfile(folder_name,'Source'))
    fprintf('Computing sol101 for Model %s',model.Name);    
    command = ['C:\MSC.Software\MSC_Nastran\20181\bin\nastran.exe',...
        ' ','sol101.bdf',...
        ' ',['out=../bin',filesep]];
    if p.Results.Silent
       command = [command,' ','1>NUL 2>NUL'];
    end
    system(command);
    cd(current_folder);
    %get Results
    data = mni.result.f06(fullfile(folder_name,'bin','sol101.f06')).read_disp();
end
