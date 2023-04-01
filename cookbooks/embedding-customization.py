from optax import apply_updates as apply
from optax import adamw

from jax import grad, jit, vmap
from jax import numpy as jnp, scipy as jsp, random
from jax.numpy import dot, square, mean
from jax.numpy.linalg import norm
from jax.scipy.special import erf


# Galois LFSR polynomial we used
RNG = random.PRNGKey(0x80000057)
OPT = adamw(1e-3)


# UTILITY FUNCTIONS
# =================

def cos(a, b): return dot(a, b) / (norm(a) * norm(b))

def mse(W, a, b, target):
    txa = jnp.dot(W, a)
    txb = jnp.dot(W, b)
    sim = cos(txa, txb)
    err = square(sim - target)
    return err

vmse = vmap(mse, (None, 0, 0, 0), 0)

def bmse(W, ba, bb, tb): return mean(vmse(W, ba, bb, tb))

@jit
def update(params, opt, ab, bb, tb):
    grads = grad(bmse)(params, ab, bb, tb)
    delta, opt = OPT.update(grads, opt, params)
    return apply(params, delta), opt


# SYNTHESIZE DATASET
# ==================

PAIRS = 100

ka, kb = random.split(RNG, 2)
ab = random.normal(ka, (PAIRS, 32))
bb = random.normal(kb, (PAIRS, 32))

kt, _ = random.split(RNG)
tb = random.uniform(kt, (PAIRS,), minval=-1.0, maxval=1.0)

IW = random.normal(RNG, (32, 32))
CW = IW


# TRAINING LOOP
# =============

EPOCHS = 100

opt = OPT.init(IW)
for epoch in range(EPOCHS): CW, opt = update(CW, opt, ab, bb, tb)

# Final weights
W = CW
# Moore-Penrose pseudoinverse
R = jnp.linalg.pinv(W)


# SANITY CHECKS
# =============

a = ab[0]
b = dot(W, a)
i = dot(R, b)
e = float(mean(jnp.abs(a - i)))
print(e)
