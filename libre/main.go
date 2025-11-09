package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
)

func main() {
	http.HandleFunc("/convert", handleConvert)
	fmt.Println("LibreOffice converter service listening on :8080")
	http.ListenAndServe(":8080", nil)
}

func handleConvert(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "use POST /convert", http.StatusMethodNotAllowed)
		return
	}

	// Parse uploaded file (multipart/form-data)
	file, header, err := r.FormFile("file")
	if err != nil {
		http.Error(w, "missing file: "+err.Error(), http.StatusBadRequest)
		return
	}
	defer file.Close()

	// Save input file to temp dir
	tmpDir, err := os.MkdirTemp("", "convert-*")
	if err != nil {
		http.Error(w, "tmp dir error: "+err.Error(), 500)
		return
	}
	defer os.RemoveAll(tmpDir)

	inputPath := filepath.Join(tmpDir, header.Filename)
	outDir := tmpDir
	outPath := filepath.Join(outDir, changeExt(header.Filename, "pdf"))

	outFile, err := os.Create(inputPath)
	if err != nil {
		http.Error(w, "create input: "+err.Error(), 500)
		return
	}
	io.Copy(outFile, file)
	outFile.Close()

	// Run LibreOffice conversion
	cmd := exec.Command("libreoffice", "--headless", "--convert-to", "pdf", "--outdir", outDir, inputPath)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		http.Error(w, "conversion failed: "+err.Error(), 500)
		return
	}

	// Serve PDF file
	result, err := os.Open(outPath)
	if err != nil {
		http.Error(w, "read output: "+err.Error(), 500)
		return
	}
	defer result.Close()

	w.Header().Set("Content-Type", "application/pdf")
	w.Header().Set("Content-Disposition", "attachment; filename=\"converted.pdf\"")
	io.Copy(w, result)
}

func changeExt(filename, newExt string) string {
	base := filepath.Base(filename)
	ext := filepath.Ext(base)
	return base[0:len(base)-len(ext)] + "." + newExt
}
