classdef Preprocessing < handle
    %PREPROCESSING Superclass for preprocessor classes for SPM 8 and 12
    properties
        output_dir = '';
        niftifs;
        spm_path = '';
        asc;
        interleaved;
    end
    
    methods
        function obj = Preprocessing(output_dir, niftifs, spm_path)
            % Constructor that takes an output directory, NiftiFS file, and
            % path to the desired SPM
            if nargin <3
                spm_path = fileparts(which('spm'));
            end
            if exist(spm_path, 'dir')
                obj.spm_path = spm_path;
            else
                error('spm_path not found');
            end
            obj.setpath();
            obj.niftifs = niftifs;
            obj.output_dir = output_dir;
        end
        
        function batch = run_slice_timing(obj, matlabbatch, TR, slice_vector, ref_slice, subject_array)
            % runs SPM slice timing
            
            % eg. run_slice_timing(obj, obj.get_matlabbatch('slice_timing'), 2,
            %   get_slice_vector(obj, 30, 1, 1), 20,
            %   get_subj_scans(obj.niftifs))
            if nargin < 6
                subject_array = get_subject_array(obj.niftifs);
            end
            number_slices = max(slice_vector);
            TA = TR-(TR/number_slices);
            matlabbatch{1}.spm.temporal.st.scans = {}; % image list
            matlabbatch{1}.spm.temporal.st.nslices = number_slices; % number of slices
            matlabbatch{1}.spm.temporal.st.tr = TR; % TR
            matlabbatch{1}.spm.temporal.st.ta = TA; % TA
            matlabbatch{1}.spm.temporal.st.so = slice_vector; % scan order
            matlabbatch{1}.spm.temporal.st.refslice = ref_slice;
            initialize_spm(obj);
            
            runs = obj.get_runs(subject_array);
            batch = {};
            for i=1:size(runs, 1)
                try
                    scans = runs{i}.get_scans;
                    vol = spm_vol(strrep(scans{1,1}, ',1', ''));
                    if size(vol,1)>1
                        vol = vol(1);
                    end
                    if min(vol.dim) ~= max(slice_vector)
                        matlabbatch{1}.spm.temporal.st.nslices = min(vol.dim);
                        matlabbatch{1}.spm.temporal.st.so = obj.get_slice_vector(min(vol.dim), obj.asc, obj.interleaved);
                    end
                    matlabbatch{1}.spm.temporal.st.scans = {runs{i}.get_scans};
                    batch(end+1) = matlabbatch;
                catch
                    warning(['Run: ' num2str(i) 'has not run']);
                end
            end
            batch = batch';
        end
        
        function batch = run_realignment(obj, matlabbatch, subjects)
            % run SPM realignment
            
            % eg. run_realignment(obj, obj.get_matlabbatch('realign'), subjs)
            if nargin < 3
                subjects = get_subject_array(obj.niftifs);
            end
            current_dir = obj.initialize_spm('realign');
            runs = obj.get_runs(subjects);
            batch = {};
            for i=1:size(runs, 1)
                scans = runs{i}.get_scans;
                matlabbatch{1}.spm.spatial.realign.estwrite.data = {scans};
                try
                    batch(end+1) = matlabbatch;
                catch
                    warning(['Run at: ' runs{i}.path 'has not run']);
                end
            end
            psfile = dir([pwd filesep 'spm_*20*.ps']);
            if size(psfile,1) ==1
                movefile(psfile.name, ['realignment_' date '.ps']);
            end
            cd(current_dir);
            batch = batch';
        end
        
        function run_realignment_unwarp(obj, matlabbatch, subjects)
            % run SPM realign and unwarp
            
            % eg. run_realignment_unwarp(obj,
            %   obj.get_matlabbatch('realignunwarp'), PhaseMap_struct, subjs)
            if nargin < 3
                subjects = get_subject_array(obj.niftifs);
            end
            current_dir = initialize_spm(obj, 'realign');
            subjects = obj.get_runs(subjects);
            batch = {};
            for i = 1:size(subjects, 1)
                PM_file = subjects{i}.get_associated_matrix('phase_map');
                runs = subjects{i}.get_runs;
                for j = 1:size(runs, 1)
                    matlabbatch{1}.spm.spatial.realignunwarp.data.scans = runs(j).get_scans;
                    matlabbatch{1}.spm.spatial.realignunwarp.data.pmscan = {PM_file};
                    batch(end+1) = matlabbatch;
                end
            end
            psfile = dir([pwd filesep 'spm_*20*.ps']);
            if size(psfile,1) ==1
                movefile(psfile.name, ['realignunwarp_' date '.ps']);
            end
            cd(current_dir);
            batch = batch';
        end
        
        function run_coregistration(obj, matlabbatch, subject_array)
            % run SPM coregistration
            
            % eg. run_coregistration(obj, obj.get_matlabbatch('coregistration'),
            %   get_subj_scans(obj.niftifs)
            if nargin < 3
                subject_array = get_subject_array(obj.niftifs);
            end
            current_dir = initialize_spm(obj, 'coregistration');
            subjects = obj.get_runs(subject_array);
            batch = {};
            for i = 1:size(subjects,1)
                structural_scan = {subjects{i}.get_structural_path};
                if(isempty(structural_scan))
                    warning(['subject ' subjects{i}.get_id 'has no structural scan']);
                    continue;
                end
                runs = subjects{i}.get_runs;
                for j = 1:size(runs, 1)
                    try
                        mean_image = get_mean_image(obj, runs(j).get_scans, obj.niftifs.functional_directory);
                        matlabbatch{1}.spm.spatial.coreg.estimate.ref = structural_scan; % T1 image path
                        matlabbatch{1}.spm.spatial.coreg.estimate.source = mean_image; % mean image path
                        matlabbatch{1}.spm.spatial.coreg.estimate.other = runs(j).get_scans; % functional images paths
                        batch(end+1) = matlabbatch;
                    catch
                        warning(['subject ' subjects{i}.get_id ' has not run']);
                    end
                end
            end
            psfile = dir([pwd filesep 'spm_*20*.ps']);
            if size(psfile,1) ==1
                movefile(psfile.name, ['coregistration_' date '.ps']);
            end
            cd(current_dir);
            batch = batch';
        end
   
    end
    
    methods (Access = protected)
        function setpath(obj)
            % Helper function to set the desired path to SPM to the top of
            % the path
            addpath(genpath(obj.spm_path));
        end
        
        function dir = initialize_spm(obj, task)
            % initialize the SPM functions cd's to the output directory if
            % needed
            if nargin < 2
                task = '';
            end
            dir = pwd;
            setpath(obj);
            spm_jobman('initcfg');
            if strcmp(task, 'realign') || strcmp(task,'coregistration')
                cd(obj.output_dir);
                spm('FnUIsetup','realign' ,1,1);
            end
        end
        
        function vec = get_slice_vector(obj, number_slices, ascending, interleaved)
            % Takes the number of slices as number_slices, and 2 flags to
            % set if the order of slices is ascending or descending, or
            % interleaved.
            % eg. get_slice_vector(obj, 30, 1, 1)
            obj.asc = ascending;
            obj.interleaved = interleaved;
            
            if ~interleaved
                if ascending
                    vec = 1:1:number_slices;
                elseif ~ascending
                    vec = number_slices:-1:1;
                end
            else
                if ascending && mod(number_slices,2)~=0
                    vec = [1:2:number_slices 2:2:number_slices-1];
                elseif ascending && mod(number_slices,2)==0
                    vec = [1:2:number_slices-1 2:2:number_slices];
                elseif ~ascending && mod(number_slices,2)~=0
                    vec = [number_slices:-2:1 number_slices-1:-2:2];
                elseif ~ascending && mod(number_slices,2)==0
                    vec = [number_slices:-2:2 number_slices-1:-2:1];
                end
                
            end
        end
        
        function runs = get_runs(~, x)
            if isa(x, 'SubjectArray')
                runs = x.get_runs;
            else
                runs = x;
            end
        end
        
        function mean_image = get_mean_image(~, scan, directory)
            scan_folder = fileparts(scan{1,1});
            mean_image = directory.expand_folders([strsplit(scan_folder, filesep), 'mean*']);
            a = 2;
            % If mean image is not matched
            if isempty(mean_image)
                while isempty(mean_image) && directory.scan_strmatch(a) ~= '*'
                    mean_image = directory.expand_folders([strsplit(scan_folder, filesep), ['mean', directory.scan_strmatch(a:end)]]);
                    a = a+1;
                end
                mean_image = directory.expand_folders([strsplit(scan_folder, filesep), ['mean', directory.scan_strmatch(a:end)]]);
            end
        end
        
        function run_spmjobman(~, batch)
            parfor i = 1:size(batch,1)
                spm_jobman('run', batch(i));
            end
        end
    end
end

