# Copyright 2020 the Arraymancer contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import ../tensor
import math

proc gauss*[T](x, mean, sigma: T, norm = false): float =
  ## Returns a value of the gaussian distribution described by `mean`, `sigma`
  ## at position `x`.
  ##
  ## If `norm` is true the value will be normalized by `1 / sqrt(2π)`.
  ##
  ## Based on the ROOT implementation of TMath::Gaus:
  ## https://root.cern.ch/root/html524/src/TMath.cxx.html#dKZ4iB
  ##
  ## Inputs are converted to float.
  if sigma == 0:
    result = 1.0e30
  let
    arg = (x - mean).float / sigma.float
    res = exp(-0.5 * arg * arg)
  if norm == false:
    result = res
  else:
    result = res / (2.50662827463100024 * sigma) # sqrt(2*Pi)=2.5066282746310002

proc gauss*[T](x: Tensor[T], mean, sigma: T, norm = false): Tensor[float] =
  ## Returns a tensor evaluated at all positions of its values on the
  ## gaussian distribution described by `mean` and `sigma`.
  result = x.map_inline(gauss(x, mean, sigma, norm = norm))

proc box*(x: float): float =
  ## provides a box distribution
  result = if abs(x) <= 0.5: 1.0 else: 0.0

proc triangular*(x: float): float =
  ## provides a triangular distribution
  let val = abs(x)
  result = if val <= 1.0: 1.0 - val else: 0.0

proc trigonometric*(x: float): float =
  ## provides a trigonometric distribution
  let val = abs(x)
  result = if val <= 0.5: 1.0 + cos(2 * PI * val) else: 0.0

proc epanechnikov*(x: float): float =
  ## provides an Epanechnikov distribution
  let val = abs(x)
  result = if val <= 1.0: 3.0 / 4.0 * (1 - val * val) else: 0.0

template liftDistributions(fn: untyped): untyped =
  template `fn`*[T](t: Tensor[T]): Tensor[float] =
    t.map_inline(fn(x.float))

# for use with tensors, lift all distributions
liftDistributions(box)
liftDistributions(triangular)
liftDistributions(trigonometric)
liftDistributions(epanechnikov)
