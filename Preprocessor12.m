classdef Preprocessor12 < Preprocessing & handle 
    methods
        function obj = Preprocessor12(output_dir, niftifs, spm_path)
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
                case 'normalization'
                    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = {}; % T1 seg sn
                    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = {}; % image list
                    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasreg = 1.000000000000000e-04;
                    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
                    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.tpm = {fullfile(obj.spm_path, 'tpm', 'TPM.nii')};
                    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
                    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = [0,0.00100000000000000,0.500000000000000,0.0500000000000000,0.200000000000000];
                    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
                    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.samp = 3;
                    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -70 % bounding box extended to include cerebellum (-70)
                        78 76 85];
                    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.vox = [2 2 2]; % Voxel sizes = 2x2x2
                    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.interp = 1;
                    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.prefix = 'w';
                case 'smoothing'
                    matlabbatch{1}.spm.spatial.smooth.data = {}; % image list
                    matlabbatch{1}.spm.spatial.smooth.fwhm = [6,6,6] ;
                    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
                    matlabbatch{1}.spm.spatial.smooth.im = 0;
                    matlabbatch{1}.spm.spatial.smooth.prefix = 's';
                case 'newsegmentation'
                    matlabbatch{1}.spm.spatial.preproc.channel.vols = {};
                    matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
                    matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
                    matlabbatch{1}.spm.spatial.preproc.channel.write = [0 0];
                    matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[ fullfile(obj.spm_path, 'tpm', 'TPM.nii'), ',1']};
                    matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
                    matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
                    matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
                    matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm =  {[ fullfile(obj.spm_path, 'tpm', 'TPM.nii'), ',2']};
                    matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
                    matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
                    matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
                    matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm =  {[ fullfile(obj.spm_path, 'tpm', 'TPM.nii'), ',3']};
                    matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
                    matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
                    matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
                    matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm =  {[ fullfile(obj.spm_path, 'tpm', 'TPM.nii'), ',4']};
                    matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
                    matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
                    matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
                    matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = { [ fullfile(obj.spm_path, 'tpm', 'TPM.nii'), ',5']};
                    matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
                    matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
                    matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
                    matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm =  {[ fullfile(obj.spm_path, 'tpm', 'TPM.nii'), ',6']};
                    matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
                    matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
                    matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
                    matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
                    matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
                    matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
                    matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
                    matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
                    matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
                    matlabbatch{1}.spm.spatial.preproc.warp.write = [0 0];
            end
        end
        
        function batch = run_newsegmentation(obj, matlabbatch, subjects)
            if nargin < 3
                subjects = get_subject_array(obj.niftifs);
            end
            subjects = subjects.get_subjects;
            batch = {};
            for i = 1:size(subjects,1)
                try
                    matlabbatch{1}.spm.spatial.preproc.channel.vols = {subjects{i}.get_structural_path};
                    batch(end+1) = matlabbatch;
                catch
                    warning(['subject ' subjects{i}.get_id 'has not run']);
                end
                
            end
        end
        
        function batch = run_normalization(obj, matlabbatch, subjects)
            % run SPM normalization
            
            % eg. run_normalization(obj,
            %   obj.get_matlabbatch('normalization'), subjs)
            if nargin < 3
                subjects = get_subject_array(obj.niftifs);
            end
            initialize_spm(obj)
            nruns = size(subjects.get_runs,1);
            subjects = subjects.get_subjects;
            batch = {};
            for i = 1:size(subjects, 1)
                structural_scan = subjects{i}.get_structural_path;
                if(isempty(structural_scan))
                    warning(['subject ' subjects{i}.get_id 'has no structural scan']);
                    continue;
                end
                matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = {structural_scan};
                runs = subjects{i}.get_runs;
                for j = 1:size(runs, 1)
                    try
                        matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = runs(j).get_scans;
                        batch(end+1) = matlabbatch;
                    catch
                        warning(['subject ' subjects{i}.get_id 'has not run']);
                    end
                end
            end
            batch = batch';
        end
        
        function batch = run_smoothing(obj, matlabbatch, subjects)
            % run SPM smoothing
            % run_smoothing(obj, obj.get_matlabbatch('smoothing'), subjs)
            if nargin < 3
                subjects = get_subject_array(obj.niftifs);
            end
            initialize_spm(obj);
            runs = obj.get_runs(subjects);
            batch = {};
            for i = 1:size(runs, 1)
                matlabbatch{1}.spm.spatial.smooth.data = runs{i}.get_scans;
                batch(end+1) = matlabbatch;
                
            end
            batch = batch';
        end
    end
    
end