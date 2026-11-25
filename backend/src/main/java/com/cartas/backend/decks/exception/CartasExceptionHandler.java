package com.cartas.backend.decks.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.server.ResponseStatusException;

@RestControllerAdvice
public class CartasExceptionHandler {
    @ExceptionHandler(DeckNotFoundException.class)
    ProblemDetail handleDeckNotFound(DeckNotFoundException ex) {
        return ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, ex.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    ProblemDetail handleValidation(MethodArgumentNotValidException ex) {
        StringBuilder detail = new StringBuilder();
        for (FieldError error : ex.getBindingResult().getFieldErrors()) {
            detail.append(error.getField()).append(": ").append(error.getDefaultMessage()).append("; ");
        }
        return ProblemDetail.forStatusAndDetail(HttpStatus.BAD_REQUEST, detail.toString());
    }

    @ExceptionHandler(ResponseStatusException.class)
    ProblemDetail handleResponseStatusException(ResponseStatusException ex) {
        return ProblemDetail.forStatusAndDetail(ex.getStatusCode(), ex.getReason());
    }
}
