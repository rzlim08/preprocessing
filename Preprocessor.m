classdef Preprocessor < Preprocessing & handle
    methods
        function obj = Preprocessor(output_dir, niftifs, spm_path)
            obj@Preprocessing(output_dir, niftifs, spm_path);
        end
        
        function matlabbatch = get_matlabbatch(obj, step)
            % Gets the batch parameters.
            clear('matlabbatch');
            switch(step)
                case 'slice_timing'
                    matlabbatch{1}.spm.temporal.st.scans = {}; % image list
                    matlabbatch{1}.spm.temporal.st.nslices = 0; % number of slices
                    matlabbatch{1}.spm.temporal.st.tr = -1; % TR
                    matlabbatch{1}.spm.temporal.st.ta = -1; % TA
                    matlabbatch{1}.spm.temporal.st.so = -1; % scan order
                    matlabbatch{1}.spm.temporal.st.refslice = -1; % reference slice
                    matlabbatch{1}.spm.temporal.st.prefix = 'a';
                case {'realign','realignment'}
                    matlabbatch{1}.spm.spatial.realign.estwrite.data = {}; % image list
                    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9; % SPM default parameters unless specified
                    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
                    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
                    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
                    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
                    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
                    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
                    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [0 1]; % mean image only
                    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
                    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
                    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
                    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
                case 'realignunwarp'
                    matlabbatch{1}.spm.spatial.realignunwarp.data.scans = {};
                    matlabbatch{1}.spm.spatial.realignunwarp.data.pmscan = {};
                    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.quality = 0.9; % SPM default parameters unless specified
                    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.sep = 4;
                    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
                    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.rtm = 0;
                    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.interp = 2;
                    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.wrap = [0 0 0];
                    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.weight = '';
                    matlabbatch{1}.spm.spatial.realignunwarp.basfcn = [12,12];
                    matlabbatch{1}.spm.spatial.realignunwarp.regorder = 1;
                    matlabbatch{1}.spm.spatial.realignunwarp.lambda = 100000;
                    matlabbatch{1}.spm.spatial.realignunwarp.jm = 0;
                    matlabbatch{1}.spm.spatial.realignunwarp.fot = [4,5];
                    matlabbatch{1}.spm.spatial.realignunwarp.sot = [];
                    matlabbatch{1}.spm.spatial.realignunwarp.uwfwhm = 4;
                    matlabbatch{1}.spm.spatial.realignunwarp.rem = 1;
                    matlabbatch{1}.spm.spatial.realignunwarp.noi = 5;
                    matlabbatch{1}.spm.spatial.realignunwarp.expround = 'Average';
                case 'coregistration'
                    matlabbatch{1}.spm.spatial.coreg.estimate.ref = {}; % T1 image path
                    matlabbatch{1}.spm.spatial.coreg.estimate.source = {}; % mean image path
                    matlabbatch{1}.spm.spatial.coreg.estimate.other = {}; % functional images paths
                    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi'; % SPM default parameters
                    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
                    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
                    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
                case 'normalization' %spm 8
                    matlabbatch{1}.spm.spatial.normalise.write.subj.matname = {}; % T1 seg sn
                    matlabbatch{1}.spm.spatial.normalise.write.subj.resample = {}; % image list
                    matlabbatch{1}.spm.spatial.normalise.write.roptions.preserve = 0; % default SPM parameters unless specified
                    matlabbatch{1}.spm.spatial.normalise.write.roptions.bb = [-78 -112 -70 % bounding box extended to include cerebellum (-70)
                        78 76 85];
                    matlabbatch{1}.spm.spatial.normalise.write.roptions.vox = [2 2 2]; % Voxel sizes = 2x2x2
                    matlabbatch{1}.spm.spatial.normalise.write.roptions.interp = 1;
                    matlabbatch{1}.spm.spatial.normalise.write.roptions.wrap = [0 0 0];
                    matlabbatch{1}.spm.spatial.normalise.write.roptions.prefix = 'w';
                case 'smoothing'
                    matlabbatch{1}.spm.spatial.smooth.data = {}; % image list
                    matlabbatch{1}.spm.spatial.smooth.fwhm = [6,6,6] ;
                    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
                    matlabbatch{1}.spm.spatial.smooth.im = 0;
                    matlabbatch{1}.spm.spatial.smooth.prefix = 's';
                case 'segmentation'
                    spmfiles = cell(3,1); % creates cell array and next lines insert paths for relevant spm files
                    spmfiles{1} = fullfile(obj.spm_path, 'tpm/grey.nii');
                    spmfiles{2} = fullfile(obj.spm_path, '/tpm/white.nii');
                    spmfiles{3} = fullfile(obj.spm_path, '/tpm/csf.nii');
                    matlabbatch{1}.spm.spatial.preproc.data = {}; % T1 image path
                    matlabbatch{1}.spm.spatial.preproc.output.GM = [0 1 1]; % Grey Matter = Native + Unmodulated Normalized
                    matlabbatch{1}.spm.spatial.preproc.output.WM = [0 1 1]; % White Matter = Native + Unmodulated Normalized
                    matlabbatch{1}.spm.spatial.preproc.output.CSF = [0 1 1]; % CSF = Native + Unmodulated Normalized
                    matlabbatch{1}.spm.spatial.preproc.output.biascor = 1; % SPM default parameters starting here
                    matlabbatch{1}.spm.spatial.preproc.output.cleanup = 0;
                    matlabbatch{1}.spm.spatial.preproc.opts.tpm = spmfiles; % SPM files based on spm directory input
                    matlabbatch{1}.spm.spatial.preproc.opts.ngaus = [2 2 2 4];
                    matlabbatch{1}.spm.spatial.preproc.opts.regtype = 'mni';
                    matlabbatch{1}.spm.spatial.preproc.opts.warpreg = 1;
                    matlabbatch{1}.spm.spatial.preproc.opts.warpco = 25;
                    matlabbatch{1}.spm.spatial.preproc.opts.biasreg = 0.0001;
                    matlabbatch{1}.spm.spatial.preproc.opts.biasfwhm = 60;
                    matlabbatch{1}.spm.spatial.preproc.opts.samp = 3;
                    matlabbatch{1}.spm.spatial.preproc.opts.msk = {''};
            end
        end
        
        function run_segmentation(obj, matlabbatch, subjects)
            if nargin < 3
                subjects = get_subject_array(obj.niftifs);
            end
            subjects = obj.get_runs(subjects);
            batch = {};
            for i = 1:size(subjects,1)
                try
                    matlabbatch{1}.spm.spatial.preproc.data = {subjects{i}.get_structural_path};
                    batch(end+1) = matlabbatch;
                catch
                    warning(['subject ' subjects{i}.get_id 'has not run']);
                end
                
            end
            batch = batch';
        end
        
        function run_normalization(obj, matlabbatch, subjects)
            % run SPM normalization
            
            % eg. run_normalization(obj,
            %   obj.get_matlabbatch('normalization'), subjs)
            if nargin < 3
                subjects = get_subject_array(obj.niftifs);
            end
            initialize_spm(obj)
            subjects = obj.get_runs(subjects);
            for i = 1:size(subjects, 1)
                structural_scan = subjects{i}.get_structural_path;
                if(isempty(structural_scan))
                    warning(['subject ' subjects{i}.get_id 'has no structural scan']);
                    continue;
                end
                structural_folder = fileparts(structural_scan);
                seg_sn_file = obj.niftifs.functional_directory.expand_folders([strsplit(structural_folder, filesep), '*seg_sn.mat']);
                matlabbatch{1}.spm.spatial.normalise.write.subj.matname = seg_sn_file;
                runs = subjects{i}.get_runs;
                for j = 1:size(runs, 1)
                    try
                        matlabbatch{1}.spm.spatial.normalise.write.subj.resample = runs(j).get_scans;
                        spm_jobman('run', matlabbatch);
                    catch
                        warning(['subject ' subjects{i}.get_id 'has not run']);
                    end
                end
            end
        end
        
        function run_smoothing(obj, matlabbatch, subjects)
            % run SPM smoothing
            % run_smoothing(obj, obj.get_matlabbatch('smoothing'), subjs)
            if nargin < 3
                subjects = get_subject_array(obj.niftifs);
            end
            initialize_spm(obj);
            runs = obj.get_runs(subjects);
            for i = 1:size(runs, 1)
                matlabbatch{1}.spm.spatial.smooth.data = runs{i}.get_scans;
                spm_jobman('run', matlabbatch);
                
            end
        end
    end
end
