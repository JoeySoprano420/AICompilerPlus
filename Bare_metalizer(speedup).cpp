#include <iostream>
#include <vector>
#include <thread>
#include <atomic>
#include <chrono>
#include <cstdlib>
#include <immintrin.h>  // For AVX-512 and other SIMD operations
#include <mutex>
#include <omp.h>
#include <malloc.h>

// Macro to align variables to a cache-line boundary (64 bytes)
#define CACHE_LINE_SIZE 64
#define ALIGN_TO_CACHE_LINE __attribute__((aligned(CACHE_LINE_SIZE)))

// Optimized Memory Pool for better cache locality
class MemoryPool {
public:
    MemoryPool(size_t blockSize, size_t blockCount) {
        memory = _mm_malloc(blockSize * blockCount, CACHE_LINE_SIZE);  // Using _mm_malloc for better alignment
        blocks = new char*[blockCount];
        for (size_t i = 0; i < blockCount; ++i) {
            blocks[i] = static_cast<char*>(memory) + i * blockSize;
        }
        freeBlocks.store(blockCount);
    }

    ~MemoryPool() {
        _mm_free(memory);  // Use _mm_free to free memory allocated with _mm_malloc
        delete[] blocks;
    }

    void* allocate() {
        size_t freeBlockCount = freeBlocks.load();
        if (freeBlockCount > 0) {
            return blocks[freeBlockCount - 1];
        }
        return nullptr;  // Return nullptr if no memory available
    }

    void deallocate(void* ptr) {
        // In this simplified example, we won't handle memory freeing.
        // A more sophisticated memory pool would mark the block as free.
    }

private:
    void* memory;
    char** blocks;
    std::atomic<size_t> freeBlocks;  // Atomic counter to handle concurrent access safely
};

// Optimized Matrix Multiplication using AVX512
void matrix_multiply_avx512(float* A, float* B, float* C, size_t N) {
    for (size_t i = 0; i < N; i++) {
        for (size_t j = 0; j < N; j++) {
            __m512 sum = _mm512_setzero_ps();  // Zero out the accumulator
            for (size_t k = 0; k < N; k += 16) {  // Process 16 elements at a time
                __m512 a = _mm512_loadu_ps(&A[i * N + k]);  // Load 16 elements from A
                __m512 b = _mm512_loadu_ps(&B[k * N + j]);  // Load 16 elements from B
                sum = _mm512_fmadd_ps(a, b, sum);  // Perform FMA (Fused Multiply-Add)
            }
            _mm512_storeu_ps(&C[i * N + j], sum);  // Store the result in C
        }
    }
}

// Optimized Parallel Matrix Multiplication using OpenMP
void parallel_matrix_multiply_omp(float* A, float* B, float* C, size_t N, int numThreads) {
    #pragma omp parallel for num_threads(numThreads)  // Parallelize the outer loop
    for (size_t i = 0; i < N; i++) {
        for (size_t j = 0; j < N; j++) {
            float sum = 0;
            for (size_t k = 0; k < N; ++k) {
                sum += A[i * N + k] * B[k * N + j];
            }
            C[i * N + j] = sum;
        }
    }
}

// Optimized Matrix Multiplication with Manual Threading Control
void parallel_matrix_multiply_manual(float* A, float* B, float* C, size_t N, int numThreads) {
    size_t chunkSize = N / numThreads;
    std::vector<std::thread> threads;

    auto multiplyChunk = [&](size_t startRow, size_t endRow) {
        for (size_t i = startRow; i < endRow; ++i) {
            for (size_t j = 0; j < N; ++j) {
                float sum = 0;
                for (size_t k = 0; k < N; ++k) {
                    sum += A[i * N + k] * B[k * N + j];
                }
                C[i * N + j] = sum;
            }
        }
    };

    for (int i = 0; i < numThreads; ++i) {
        size_t startRow = i * chunkSize;
        size_t endRow = (i + 1) * chunkSize;
        threads.push_back(std::thread(multiplyChunk, startRow, endRow));
    }

    for (auto& t : threads) {
        t.join();
    }
}

// Function to ensure data access is cache-optimized
void optimized_data_access_pattern(float* data, size_t N) {
    // Ensure that data is accessed in a way that benefits from the cache.
    // Linear memory access patterns for better cache locality.
    for (size_t i = 0; i < N; i++) {
        data[i] = data[i] * 2.0f;  // Just a sample operation to show optimized access
    }
}

// Benchmark function to measure performance of matrix multiplication
void benchmark_matrix_multiplication(float* A, float* B, float* C, size_t N, int numThreads) {
    auto start = std::chrono::high_resolution_clock::now();
    parallel_matrix_multiply_manual(A, B, C, N, numThreads);  // Switch to desired multiplication method
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<float> duration = end - start;
    std::cout << "Matrix multiplication took: " << duration.count() << " seconds." << std::endl;
}

int main() {
    size_t N = 1024;  // Matrix size (N x N)
    int numThreads = std::thread::hardware_concurrency();  // Automatically use the maximum available threads
    std::cout << "Using " << numThreads << " threads." << std::endl;

    // Allocate memory for matrices
    float* A = new float[N * N];
    float* B = new float[N * N];
    float* C = new float[N * N];

    // Initialize matrices A and B
    for (size_t i = 0; i < N * N; ++i) {
        A[i] = static_cast<float>(i);
        B[i] = static_cast<float>(i);
    }

    // Run benchmark
    benchmark_matrix_multiplication(A, B, C, N, numThreads);

    // Deallocate memory
    delete[] A;
    delete[] B;
    delete[] C;

    return 0;
}
