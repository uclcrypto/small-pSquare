// Reference implementation. Very inefficient!
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define n 7
#define p ((1<<7)-1)
#define r_R 4
#define r_B 21

void F_function(uint8_t* f_in, uint8_t c0, uint8_t c1, uint8_t* f_out)
{
    // First Round-Constant Addition and Non-Linear Layer
    uint8_t sq1_in = (f_in[3] + c0) % p;
    uint8_t sq1_out = (sq1_in * sq1_in) % p;
    uint8_t sq2_out = (f_in[2] * f_in[2]) % p;
    uint8_t sq3_out = (f_in[1] * f_in[1]) % p;
    uint8_t mds2_in = (f_in[2] + sq1_out) % p;
    uint8_t mds3_in = (f_in[1] + sq2_out) % p;
    uint8_t mds4_in = (f_in[0] + sq3_out) % p;

    // MDS Matrix Multiplication
    uint8_t add1_12 = (sq1_in + mds2_in) % p;
    uint8_t add1_34 = (mds3_in + mds4_in) % p;
    uint8_t add2_234 = (mds2_in + add1_34) % p;
    uint8_t add2_124 = (mds4_in + add1_12) % p;
    uint8_t add1_12_2 = (2*add1_12) % p;
    uint8_t add1_34_2 = (2*add1_34) % p;
    uint8_t mds4_out = (add1_34_2 + add2_124) % p;
    uint8_t mds2_out = (add1_12_2 + add2_234) % p;
    uint8_t add2_124_4 = (4*add2_124) % p;
    uint8_t add2_234_4 = (4*add2_234) % p;
    uint8_t mds1_out = (add2_124_4 + mds2_out) % p;
    uint8_t mds3_out = (add2_234_4 + mds4_out) % p;

    // Second Round-Constant Addition and Non-Linear Layer
    f_out[3] = (mds1_out + c1) % p;
    uint8_t sq4_out = (f_out[3] * f_out[3]) % p;
    uint8_t sq5_out = (mds2_out * mds2_out) % p;
    uint8_t sq6_out = (mds3_out * mds3_out) % p;
    f_out[0] = (mds2_out + sq4_out) % p;
    f_out[1] = (mds3_out + sq5_out) % p;
    f_out[2] = (mds4_out + sq6_out) % p;
}

void UpdateRoundTweak(uint8_t* round_tweak)
{
    uint8_t tmp[16];
    tmp[0] = round_tweak[9];
    tmp[1] = round_tweak[5];
    tmp[2] = round_tweak[13];
    tmp[3] = round_tweak[15];
    tmp[4] = round_tweak[12];
    tmp[5] = round_tweak[7];
    tmp[6] = round_tweak[14];
    tmp[7] = round_tweak[2];
    tmp[8] = round_tweak[4];
    tmp[9] = round_tweak[6];
    tmp[10] = round_tweak[8];
    tmp[11] = round_tweak[3];
    tmp[12] = round_tweak[10];
    tmp[13] = round_tweak[1];
    tmp[14] = round_tweak[11];
    tmp[15] = round_tweak[0];
    for(int i=0; i<16; i++)
    {
        round_tweak[i] = ((tmp[i] << (i % n)) & p) | (tmp[i] >> (n - (i % n)));
        round_tweak[i] = (((round_tweak[i] >> 0) & 0x1) << 5) |
                         (((round_tweak[i] >> 1) & 0x1) << 3) |
                         (((round_tweak[i] >> 2) & 0x1) << 0) |
                         (((round_tweak[i] >> 3) & 0x1) << 4) |
                         (((round_tweak[i] >> 4) & 0x1) << 1) |
                         (((round_tweak[i] >> 5) & 0x1) << 6) |
                         (((round_tweak[i] >> 6) & 0x1) << 2);

    }
}

void InverseUpdateRoundTweak(uint8_t* round_tweak)
{
    for(int i=0; i<16; i++)
    {
        round_tweak[i] = (((round_tweak[i] >> 5) & 0x1) << 0) |
                         (((round_tweak[i] >> 3) & 0x1) << 1) |
                         (((round_tweak[i] >> 0) & 0x1) << 2) |
                         (((round_tweak[i] >> 4) & 0x1) << 3) |
                         (((round_tweak[i] >> 1) & 0x1) << 4) |
                         (((round_tweak[i] >> 6) & 0x1) << 5) |
                         (((round_tweak[i] >> 2) & 0x1) << 6);
        round_tweak[i] = ((round_tweak[i] << (n - (i % n))) & p) | (round_tweak[i] >> (i % n));
    }
    uint8_t tmp[16];
    tmp[0] = round_tweak[15];
    tmp[1] = round_tweak[13];
    tmp[2] = round_tweak[7];
    tmp[3] = round_tweak[11];
    tmp[4] = round_tweak[8];
    tmp[5] = round_tweak[1];
    tmp[6] = round_tweak[9];
    tmp[7] = round_tweak[5];
    tmp[8] = round_tweak[10];
    tmp[9] = round_tweak[0];
    tmp[10] = round_tweak[12];
    tmp[11] = round_tweak[14];
    tmp[12] = round_tweak[4];
    tmp[13] = round_tweak[2];
    tmp[14] = round_tweak[6];
    tmp[15] = round_tweak[3];
    for(int i=0; i<16; i++) round_tweak[i] = tmp[i];
}

void ComputeRoundTweakey(uint8_t* round_tweak, const uint8_t* key, uint8_t* round_tweakey)
{
    for(int i=0; i<16; i++) round_tweakey[i] = (round_tweak[i] + key[i]) % p;
}

void AddRoundTweakey(uint8_t* round_state, uint8_t* round_tweakey)
{
    for(int i=0; i<16; i++) round_state[i] = (round_state[i] + round_tweakey[i]) % p;
}

void InverseAddRoundTweakey(uint8_t* round_state, uint8_t* round_tweakey)
{
    for(int i=0; i<16; i++) round_state[i] = (round_state[i] + p - round_tweakey[i]) % p;
}

int Encrypt(const uint8_t *plaintext, const uint8_t* key, const uint8_t* tweak0, const uint8_t* tweak1, uint8_t *ciphertext)
{
    uint8_t state[16];
    uint8_t round_tweak0[16];
    uint8_t round_tweak1[16];
    uint8_t round_tweakey[16];
    uint64_t pi = 0xC90FDAA22168C234;

    for(int i=0; i<16; i++)
    {
        state[i] = plaintext[i];
        round_tweak0[i] = tweak0[i];
        round_tweak1[i] = tweak1[i];
    }

    // Rounds
    for(int i=0; i<r_B; i++)
    {
        if((i%2) == 0)
        {
            ComputeRoundTweakey(round_tweak0, key, round_tweakey);
            UpdateRoundTweak(round_tweak0);
        }else{
            ComputeRoundTweakey(round_tweak1, key, round_tweakey);
            UpdateRoundTweak(round_tweak1);
        }
        // Add tweakey
        AddRoundTweakey(state, round_tweakey);

        // One block B
        for(int j=0; j<r_R; j++)
        {
            uint8_t c0 = (pi & p);
            uint8_t c1 = ((pi >> 48) & p);
            uint8_t c2 = ((pi >> 32) & p);
            uint8_t c3 = ((pi >> 16) & p);
            pi = (pi << 1) | (pi >> 63);

            // Apply F function
            uint8_t f_out1[4];
            uint8_t f_out2[4];
            F_function(&state[0], c0, c1, f_out1);
            F_function(&state[8], c2, c3, f_out2);

            // Apply Feistel
            uint8_t tmp[16];
            for(int k=0; k<4; k++)
            {
                tmp[k] = (state[k+4] + f_out1[3-k]) % p;
                tmp[k+4] = state[k+8];
                tmp[k+8] = (state[k+12] + f_out2[3-k]) % p;
                tmp[k+12] = state[k];
            }
            for(int k=0; k<16; k++) state[k] = tmp[k];
        }
    }
    // Final tweakey addition
    ComputeRoundTweakey(round_tweak1, key, round_tweakey);
    AddRoundTweakey(state, round_tweakey);

    for(int i=0; i<16; i++)
        ciphertext[i] = state[i];

    return 1;
}

int Decrypt(const uint8_t *ciphertext, const uint8_t* key, const uint8_t* tweak0, const uint8_t* tweak1, uint8_t *plaintext)
{
    uint8_t state[16];
    uint8_t round_tweak0[16];
    uint8_t round_tweak1[16];
    uint8_t round_tweakey[16];
    uint64_t pi = 0xC90FDAA22168C234;

    for(int i=0; i<16; i++)
    {
        state[i] = ciphertext[i];
        round_tweak0[i] = tweak0[i];
        round_tweak1[i] = tweak1[i];
    }

    // Get pi state
    pi = (pi << ((r_B*r_R) % 64)) | (pi >> (64-((r_B*r_R) % 64)));
    // Get last round tweaks
    for(int i=0; i<(r_B-1)/2; i++)
    {
        UpdateRoundTweak(round_tweak0);;
        UpdateRoundTweak(round_tweak1);
    }

    // Rounds
    for(int i=0; i<r_B; i++)
    {
        if((i%2) == 1)
        {
            ComputeRoundTweakey(round_tweak0, key, round_tweakey);
            InverseUpdateRoundTweak(round_tweak0);
        }else{
            ComputeRoundTweakey(round_tweak1, key, round_tweakey);
            InverseUpdateRoundTweak(round_tweak1);
        }
        // Add tweakey
        InverseAddRoundTweakey(state, round_tweakey);

        // One block B
        for(int j=0; j<r_R; j++)
        {
            pi = (pi << 63) | (pi >> 1);
            uint8_t c0 = (pi & p);
            uint8_t c1 = ((pi >> 48) & p);
            uint8_t c2 = ((pi >> 32) & p);
            uint8_t c3 = ((pi >> 16) & p);

            uint8_t f_out1[4];
            uint8_t f_out2[4];
            F_function(&state[12], c0, c1, f_out1);
            F_function(&state[4], c2, c3, f_out2);

            // Apply Feistel
            uint8_t tmp[16];
            for(int k=0; k<4; k++)
            {
                tmp[k] = state[k+12];
                tmp[k+4] = (state[k] + p - f_out1[3-k]) % p;
                tmp[k+8] = state[k+4];
                tmp[k+12] = (state[k+8] + p - f_out2[3-k]) % p;
            }
            for(int k=0; k<16; k++) state[k] = tmp[k];
        }
    }
    // Final tweakey addition
    ComputeRoundTweakey(round_tweak0, key, round_tweakey);
    InverseAddRoundTweakey(state, round_tweakey);

    for(int i=0; i<16; i++)
        plaintext[i] = state[i];

    return 1;
}

int main()
{
    uint8_t plaintext[16]   = {0x52, 0x30, 0x34, 0x67, 0x37, 0x0d, 0x0e, 0x27, 0x24, 0x57, 0x48, 0x62, 0x7b, 0x6f, 0x7b, 0x19};
    uint8_t key[16]         = {0x2d, 0x60, 0x05, 0x6d, 0x3b, 0x2e, 0x0c, 0x1e, 0x15, 0x2a, 0x6b, 0x55, 0x07, 0x11, 0x10, 0x26};
    uint8_t tweak0[16]      = {0x32, 0x39, 0x49, 0x5a, 0x5d, 0x2f, 0x0d, 0x20, 0x70, 0x77, 0x41, 0x5f, 0x5f, 0x5c, 0x16, 0x61};
    uint8_t tweak1[16]      = {0x5c, 0x7d, 0x24, 0x53, 0x22, 0x79, 0x36, 0x2d, 0x0c, 0x46, 0x4d, 0x7e, 0x5a, 0x2a, 0x4f, 0x26};
    uint8_t ciphertext[16];

    if(Encrypt(plaintext, key, tweak0, tweak1, ciphertext))
    {
        for(int i=0; i<15; i++)
        {
            printf("0x%02X, ", ciphertext[i]);
        }
        printf("0x%02X\n", ciphertext[15]);
    }

    if(Decrypt(ciphertext, key, tweak0, tweak1, plaintext))
    {
        for(int i=0; i<15; i++)
        {
            printf("0x%02X, ", plaintext[i]);
        }
        printf("0x%02X\n", plaintext[15]);
    }

    return 0;
}
