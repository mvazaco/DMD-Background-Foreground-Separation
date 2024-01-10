function [X_DMD, X_LowRank_DMD, X_Sparse_DMD, n_frames, omega_bg] = video_DMD(X, threshold, r)

    n_frames = size(X,2);
    
    X1=X(:,1:end-1);
    X2=X(:,2:end);
    
    %% SVD
    [U,Sigma,V] = svd(X1,'econ');
    Ur = U(:,1:r);
    Sigmar = Sigma(1:r,1:r);
    Vr = V(:,1:r);
    
    %% Build Atilde and DMD Modes
    Atilde = Ur'*X2*Vr/Sigmar; % (7.20 book)
    [W, D] = eig(Atilde);
    lambda = diag(D);
    
    % Phi = Ur * W;
    Phi = X2 * Vr / Sigmar *W;  % DMD Modes (7.23 book)
    
    %% Spectral Decomposition and DMD Expansion
    
    alpha1 = Sigmar * Vr(1,:)'; % (Code 7.3 book)
    b = (W * diag(lambda)) \ alpha1;
    % b = (W * diag(lambda)) \ Ur' * X(:,1); %(7.32f book)
    % b = Phi_fg \ X(:, 1);
    % b = pinv(Phi) * X(:, 1);
    
    dt=1/60; %fps
    omega = log(lambda)/(dt); %(page 265)
    % plot(omega, 'o')
    
    % b_e_wt = diag(b) * e_wt;
    
    % for i = 1:r
    %     figure()
    %     plot(real(e_wt(i,1:100))), hold on
    %     plot(imag(e_wt(i,1:100)),'--')
    %     title(['Oscillation of \omega_{', num2str(i), '} in Time'])
    %     xlabel('Time (frame#)')
    %     ylabel('Amplitude')
    %     legend('Mode Evolution (real)','Mode Evolution (imaginary)', 'Location', 'best');
    % end
    % k = 1;
    % figure()
    % plot(real(e_wt(k,1:150))),
    % plot(imag(e_wt(k,1:150)),'--')
    % title(['Oscillation of \omega_{', num2str(k), '} in Time'])
    % xlabel('Time (frame#)')
    % ylabel('Amplitude')
    % legend('Mode Evolution (real)','Mode Evolution (imaginary)', 'Location', 'best');
    
    % % spectra of S around complex unit circle
    % figure(2)
    % plot(cos(0:pi/50:2*pi),sin(0:pi/50:2*pi),imag(lambda),real(lambda),'r.')
    % title('Complex Exponential Eigenvalues')
    % xlabel('Real Component')
    % ylabel('Imaginary Component')
    % legend('Unit Circle','Eigenvalues')
    
    %% BG & FG separation
    bg = find(abs(omega)<threshold);
    omega_bg = omega(bg);
    if length(bg)>1
        error('More than one omega found for computing background! Reduce threshold')
    elseif length(bg)<1
        error('No omega found for computing background! Increase threshold')
    end
    
    %% DMD Reconstruction
    omega(bg) = 0;
    tt = (0:n_frames-1);
    e_wt = exp(omega * tt);

    % X_DMD = Phi * diag(b) * e_wt; %(7.34 book)
    % X_DMD_2 = Phi * e_wt * diag(b);
    
    X_LowRank_DMD = b(bg) * Phi(:,bg) * e_wt(bg, :);
    % X_LowRank_DMD = Phi(:,bg) * (Phi_bg\X(:, 1)) * e_wt(bg,:); %DMD Book
    
    % for i = 1:n_frames
    %     if i ~= bg
    %         X_Sparse_DMD =+ b(i) * Phi(:,i) * e_wt(i, :);
    %     end
    % end
    % X_DMD = X_LowRank_DMD + X_Sparse_DMD;
    
    X_Sparse_DMD = X - abs(X_LowRank_DMD);
    % X_Sparse_DMD = abs(X_DMD) - abs(X_LowRank_DMD);
    
    negIndices = find(X_Sparse_DMD < 0);
    R = zeros(size(X_Sparse_DMD));
    R(negIndices) = X_Sparse_DMD(negIndices);
    
    X_LowRank_DMD = R + abs(X_LowRank_DMD);
    X_Sparse_DMD  = X_Sparse_DMD - R;
    
    X_DMD = X_LowRank_DMD + X_Sparse_DMD;
    
end