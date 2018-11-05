Data from 

http://ailab.criteo.com/criteo-uplift-prediction-dataset/

From the link above:

"Data description
This dataset is constructed by assembling data resulting from several incrementality tests, a particular randomized trial procedure where a random part of the population is prevented from being targeted by advertising. it consists of 25M rows, each one representing a user with 11 features, a treatment indicator and 2 labels (visits and conversions).

Privacy
For privacy reasons the data has been sub-sampled non-uniformly so that the original incrementality level cannot be deduced from the dataset while preserving a realistic, challenging benchmark. Feature names have been anonymized and their values randomly projected so as to keep predictive power while making it practically impossible to recover the original features or user context.

Fields
Here is a detailed description of the fields (they are comma-separated in the file):

f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11: feature values (dense, float)
treatment: treatment group (1 = treated, 0 = control)
conversion: whether a conversion occured for this user (binary, label)
visit: whether a visit occured for this user (binary, label)
exposure: treatment effect, whether the user has been effectively exposed (binary)"
