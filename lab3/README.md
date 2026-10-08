# Lab 3

Production AWS accounts use OIDC so build servers get temporary permissions on the spot, avoiding stored passwords that need constant updating.

This course uses temporary session credentials because AWS Academy blocks setting up OIDC, but security risks stay low since those keys stop working when your lab time runs out.
